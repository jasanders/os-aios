#!/bin/sh 
# $Id$
set -u  #Abort with unset variables
set -e  #Abort with any error (can be suppressed locally using EITHER cmd||true OR set -e;cmd;set +e
#
#
# unpak.sh - 
#   nzbget post processing script for Popcornhour. Based on the one release
# with the August 2008 firmware.
#
# The script just uses syntax/commands found on the Popcorn Hour (busybox/ash)
# So not all commands are present (eg wc,tail) and some do not support GNU switches.
# TODO Problem displaying '%' in nzbget.log test INFO and echo
# TODO Dont copy flag files to RECENT
# TODO Fix double title match.. eg nzb=blah s01e03 .. blah ..s01e03.nzb

#
VERSION=20081009-BETA05
#   Small bugfix detected rar parts.
#VERSION=20081009-BETA04
#   Small bugfix for extracting name from nfo
#VERSION=20081009-BETA03
#   Allow _partnnn (underscore)
#VERSION=20081009-BETA02
#   Also Get TV Name from NFO file if available.
#   Small bug fixes.
#VERSION=20081002-BETA01
#   Added PIN:FOLDER 'hack' until Parental lock arrives.
#   Auto Category looks at NZB name in preference to media names
#   Added Recently Downloaded folders (using managed hard links)
#   Added IMDB Movie categorisation.
#   Diskspace check
#   Checked unrar status 'All OK' in stdout.
#   many bugfixes.
#VERSION=20080911-01
#   Option to pause for entire duration of script.
#   Fixed MOVE_RAR_CONTENTS to use -e test rather than -f
#   Fixed Par repair bug (failing to match par files to rar file)
# VERSION=20080909-02
#   Fixed MOVE_RAR_CONTENTS to use mv checkingfor hidden files and avoiding glob failure.
# VERSION=20080909-01
#   Do a par repair if there are no rar files at all (using *.par2 not *PAR2) eg for mp3 folders.
#   Fixed subtitle rar overwriting main rar if they have the same name.
#   Autocategory for Music and simple TV series names. 
#   Join avi files if not joined by nzbget.
# VERSION=20080905-03
#   Minor Bug Fix - removed symlink to par2
#VERSION=20080905-02
#   Typo Bug Fix
#VERSION=20080905-01
#   Specify Alternative Completed location
#   Log Estimate of time to Repair Pars and only do repairs that will be less than n minutes (configurable)
#   Better logic to work with twin rar,par sets (eg cd1,cd2) where one rar works but the other needs pars.
#   Better logic to work with missing start volumes.
#   Stopped using hidden files as they prevent deleting via Remote Control
#   Rar Parts are deleted right at the end of processing rather than during. This may help with pars that span multiple rar sets.
#VERSION=20080902-01
#   Better checks to ensure settings are consistent between nzbget.conf and unpak.sh.
#   Copied logic used by nzbget to convert an NZB file name to the group/folder name.
# v 20080901-02
#   Bug fix - getting ids when there are square brackets or certain meta-characters in nzb name.
# v 20080901-01
#   Bug fixes. Settings verification.
# v 20080831-04
#  External Par Repair option
# v 20080831-03
#   Minor fixes.
# v 20080831-01
#   Sanity check if nzbget did not do any par processing.
#   NZBGet , unrar paths set as options.
#   Unpacking depth configurable.
#   MediaCentre feature: HTML Logging for viewing in file browser mode.
#   MediaCentre feature: Error Status via fake AVI file
#   More bug fixes. (Rar Sanity Check)
# v 20080828-03
#   Added better test for ParCheck/_unbroken courtesy Hugbug.
# v 20080828-02
#   Fixed nested unrar bug.
#   Added purging of old NZBs
# v 20080828-01
#   Does a quick sanity check on the rar file before unpacking. 
#   added IFS= to stop read command trimming white space.
# v 20080827-02 
#   Fixed multiple attempts to unpack failed archives
# v 20080827-01 
# - Delete files only if unrar is sucessful.
# - Cope with multiple ts files in the same folder.
# - Deleting is on by default - as it is more careful
# --------------------------------------------------------------------
# Copyright (C) 2008 Peter Roubos <peterroubos @ hotmail.com>
# Copyright (C) 2008 Otmar Werner
# Copyright (C) 2008 Andrei Prygounkov <hugbug @ users.sourceforge.net>
# Copyright (C) 2008 Andrew Lord <nzbget @ lordy.org.uk>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Notes
# Careful using ls * if there are directories (ls -d *)

#########################################################################
# Settings section - see unpak.cfg.example
#########################################################################
# Settings are read from the file specified. If the file does not exist
# it will be created from the unpak.cfg.example file.
# If unpak_load_settings starts with '/' it's location is absolute,
# otherwise it is relative to the location of this script.
unpak_load_settings=/usr/local/etc/newsbin/conf/unpak.cfg

########################################################################
# SECTION: LOGGING FUNCTIONS
########################################################################

LOGSTREAM() {
    label="$1" ; shift;
    prefix="$1" ; shift
    while IFS= read x ; do
        if [ -n "$x" ] ; then
            LOG "$label" "$prefix:$x"
        fi
    done
}
LOG() {
    label="$1" ; shift;
    if [ -n "$*" ] ; then
        echo "[$label] $@"  >&2 
    fi
}

INFO() { LOG INFO "$@" ; }
WARNING() { LOG WARNING "$@" ; }
ERROR() { LOG ERROR "$@" ; }
DEBUG() { LOG DEBUG "$@"; }

LOG_END() {
    s=
    if WAITING_FOR_PARS ; then s="Waiting for PARS" ; fi
    if [ "$gUnrarState" == "OK" ] ; then
        INFO " ====== Post-process Finished : $1 : $NZB_NICE_NAME : $s $(date '+%T') ======"
    else
        ERROR " ====== Post-process Finished : $1 : $NZB_NICE_NAME : $s $(date '+%T') ======"
    fi
}

########################################################################
# SECTION: CONFIG FUNCTIONS
########################################################################

#Get nzbget's settings. Not these are read direct from the config file
#and not the ones that nzbget may be using internally??
LOAD_NZBGET_SETTINGS() {
    #eg ParCheck will become nzbget_ParCheck
    #Get all lines with / = / remove spaces around '=' , prefix with nzbget_ , replace x.y=z with x_y=z
    NZBGET -p | grep ' = ' | sed 's/^/nzbget_/;s/ = /=/;s/\.\([^=]*\)=/_\1=/' | grep -v 'nzbget_server' > $gTmpFile.nzb_cfg
    . $gTmpFile.nzb_cfg
    rm $gTmpFile.nzb_cfg
    set | grep '^nzbget_' | LOGSTREAM DEBUG "conf"
}

SET_DEFAULT_SETTINGS() {

    # :r! grep '^unpak_' /mnt/popcorn/.nzbget/unpak.cfg  | grep -v subfolder
    unpak_settings_version=1
    unpak_nzbget_bin="/usr/local/etc/newsbin/bin/nzbget"
    unpak_nzbget_conf="/usr/local/etc/newsbin/bin/nzbget.conf"
    unpak_unrar_bin="/opt/bin/unrar"
    unpak_par2_bin="/opt/bin/par2"
    unpak_completed_dir="/usr/local/etc/newsbin/usenet/download" #Default location for completed downloads

    unpak_recent_age=6
    unpak_recent_dir="/usr/local/etc/newsbin/usenet/New"    #Contains hard links to files < 2days old
    unpak_recent_age2=13
    unpak_recent_dir2="/usr/local/etc/newsbin/usenet/Recent" #Contains hard links to files < 7days old
    unpak_delete_from_recent_deletes_original=0

    unpak_auto_categorisation_from_filenames=1
    unpak_auto_categorisation_from_newsgroups=1
    unpak_auto_categorisation_from_imdb=0
    unpak_imdb_movie_format="{TITLE}{ [CERT]}{ [GENRE_LIST]}{ NZB}"
    unpak_imdb_title_country_filter="UK,USA"
    unpak_imdb_certificate_country_filter="UK,USA"

    unpak_recent_extensions=".avi,.iso,.img,.mkv"
    unpak_auto_categorisation=1
    unpak_category_default=Unsorted
    unpak_episodes_in_same_folder=1
    unpak_debug_mode=0
    unpak_sanity_check_rar_files=1
    unpak_rename_img_to_iso=1
    unpak_check_for_new_versions=0
    unpak_nmt_html_logging=0
    unpak_nmt_alert_using_fake_files=1
    unpak_nmt_fake_file_extensions=".avi"
    unpak_delete_rar_files=1
    unpak_max_nzbfile_age=30
    unpak_nested_unrar_depth=3
    unpak_disable_external_par_repair=0
    unpak_external_par_repair_tidy_queue=1
    unpak_pause_nzbget=0
    unpak_pause_nzbget_during_unrar=0
    unpak_maximum_par_repair_minutes=300
    unpak_nmt_pin_flag="PIN:FOLDER"
    unpak_nmt_pin_folder_scrample_windows_share=1
    unpak_nmt_pin_root="/usr/local/etc/newsbin/usenet/Other"
    unpak_nmt_pin="0" 
    unpak_episodes_folder_case=caps 
    unpak_rename_existing_episode_folders=0
}

unpak_settings_version=1
# Cant call logging yet.
MERGE_UNPAK_SETTINGS() {

    case "$unpak_load_settings" in
        /*) true;;
        *) unpak_load_settings="$SCRIPT_FOLDER/$unpak_load_settings" ;;
    esac

    INFO "MERGE_UNPAK_SETTINGS [$unpak_load_settings]"

    if [ -n "$unpak_load_settings" ] ; then
        #If there is no sample cfg - create one
        if [ ! -f "$unpak_load_settings" ] ; then
            cp "$SCRIPT_FOLDER/unpak.cfg.example" "$unpak_load_settings"
            echo "Create $unpak_load_settings file from example"
        fi

        if [ -f "$unpak_load_settings" ] ; then
            if egrep -q "^ *unpak_settings_version=('|)$unpak_settings_version($|[^0-9])" "$unpak_load_settings" ; then
                echo "Loading settings from $unpak_load_settings"
                . "$unpak_load_settings"
            else
                echo "Settings in $unpak_load_settings ignored. Not compatible"
            fi
        else
            echo "Using Default Settings"
        fi
    fi
}

CHECK_SETTINGS() {
    settings=0
    LOAD_NZBGET_SETTINGS
    if [ "$nzbget_ParCheck" = "yes" ] ; then
        INFO "config: Mandatory parchecking already enabled in nzbget.conf"
        external_par_check=0
    else
        if [ "$unpak_disable_external_par_repair" -eq 1 ] ; then
            INFO "config: ALL parchecking/reparing is completely disabled."
            external_par_check=0
        else
            if [ "$arg_par_check" -eq 0 ]; then 
                INFO "config: Parchecking enabled in $SCRIPT_NAME"
                external_par_check=1
            else
                ERROR "config: nzbget has Parchecked although this is disabled in nzbget.conf. May need to restart nzbget"
                external_par_check=0
            fi
        fi
    fi
    if [ "$external_par_check" -eq 1 ] ; then
#        if [ "$unpak_delete_rar_files" -eq 0 ] ; then
#           ERROR "config:unpak_delete_rar_files should be set if using external par repair feature"
#           NMT_FAKEFILE ERR "CONFIG unpak_delete_rar_files must be set in unpak.sh"
#           settings=1
#       fi
        if [ "$nzbget_LoadPars" != "all" ] ; then
            if [ "$nzbget_AllowReProcess" != "yes" ] ; then
                WARNING "config: IF LoadPars is not all then AllowReProcess should be yes in nzbget.conf"
                NMT_FAKEFILE WARN "CONFIG AllowReProcess should be yes in nzbget.conf"
               settings=1
            fi
        else
            if [ "$nzbget_AllowReProcess" = "yes" ] ; then
                WARNING "config: If AllowReProcess is 'yes' then its more efficient to set LoadPars=none in nzbget.conf"
            fi
        fi
    fi
    [ "$settings" -eq 0 ]
}

#####################################################################
# SECTION: PAR REPAIR
#####################################################################

par_flag="unpak.need.pars";
SET_WAITING_FOR_PARS() { touch "$par_flag" ; }
CLEAR_WAITING_FOR_PARS() { rm -f "$par_flag" ; }
WAITING_FOR_PARS() { [ -e "$par_flag" ] ; }

GET_PAUSED_IDS() {
    # Look in the nzbget list for the given group.

    # search list using fgrep to avoid metacharacter issues '][.'
    # However this may lead to substring matches (no anchoring), so surround the group name with
    #asterisks first as these cannot appear inside an group name.
    ids=$(NZBGET -L | sed 's/ / */;s,/,*/,' | fgrep "*$NZB_NICE_NAME*/" | sed -n '/[Pp][Aa][Rr]2 (.*paused)$/ s/^\[\([0-9]*\)\].*/\1/p')
    echo $ids | sed 's/ /,/g'
}
#Unpauses par files. Returns error if nothing to unpause.
UNPAUSE_PARS_AND_REPROCESS() {
    if [ "$nzbget_AllowReProcess" != "yes" ] ; then
        ERROR "AllowReProcess disabled. Cannot repair"
        NMT_FAKEFILE ERR "AllowReProcess disabled. Cannot repair"
        return 1
    fi
    INFO "Downloading pars in $arg_nzb_file"
    ids=$(GET_PAUSED_IDS)
    if [ -n "$ids" ] ; then
        NZBGET -E U $ids
        NZBGET -E T $ids
        SET_WAITING_FOR_PARS
    else
        return 1
    fi
}
DELETE_PAUSED_PARS() {
    if [ "$unpak_external_par_repair_tidy_queue" -eq 1 ] ; then
        INFO "Deleting paused parts of $arg_nzb_file"
        ids=$(GET_PAUSED_IDS)
        if [ -n "$ids" ] ; then
            NZBGET -E D $ids
        fi
    fi
}

#Spent over an hour before realising permisions not set properly on par2!
#Make an executable copy so users dont need to telnet in
NMT_FIX_PAR2_PERMISSIONS() {
    if [ ! -x "$unpak_par2_bin" ] ; then
        PAR2Alternative=/share/.nzbget/par2
        if [ -x "$PAR2Alternative" ] ; then
            unpak_par2_bin="$PAR2Alternative"
        else
            cp "$unpak_par2_bin" "$PAR2Alternative"
            chmod o+x "$PAR2Alternative"
            if [ ! -x "$PAR2Alternative" ] ; then
                ERROR "Make sure $unpak_par2_bin has execute permissions"
                NMT_FAKEFILE ERR "Change permissions on par2 executable"
            else
                unpak_par2_bin="$PAR2Alternative"
            fi
        fi
    fi
}

#In case there are two or more par sets just look for .par2 files. (not PAR2 files)
#TODO. We may need to know which Pars fix which rars in future so we can be more
#selective with unraring when errors occur. But for now take an all or nothing approach.
PAR_REPAIR_ALL() {
    INFO "Start Par Repair"
    NMT_FIX_PAR2_PERMISSIONS

    #First identify parsets for all FAILED or UNKNOWN rars.
    if NO_RARS ; then
        # Maybe mp3s etc. Just look at *.par2.
        # TODO. Identify par sets correctly rather than just looking at *par2
        for p in *.par2 ; do
            if [ -f "$p" ] ; then
                PAR_REPAIR "$p" || true
            fi
        done
    else
        #Fix all broken rars only. These will only be top level rars.
        LIST_RAR_STATES "(FAILED|UNKNOWN)" | while IFS= read rarPart ; do
            #Find the first par file that looks like it may fix the rar file.
            #TODO This may fail with accidental substring matches. But its quick and easy
            #TODO optimize search all par2 first then PAR2
            INFO "Finding PARS for $rarPart"
            for p in *.par2 *.PAR2 ; do
                if [ -f "$p" ] && fgrep -l "$rarPart" "$p" > /dev/null ; then
                    if PAR_REPAIR "$p" ; then
                        SET_RAR_STATE "$rarPart" REPAIRED
                    fi
                    break
                fi
            done
        done
    fi
}

PAR_REPAIR() {
    parFile="$1"

    INFO "Par Repair using $parFile"

    if [ "$pause_nzbget_during_par2repair" -eq 1 ] ; then
        PAUSE_NZBGET
    fi

    set +e
    out=$gTmpFile.p2_out
    err=$gTmpFile.p2_err
    PAR_MONITOR "$out" "$$" &
    "$unpak_par2_bin" repair "$parFile" > "$out" 2>"$err"
    par_state=$?
    set -e

    if [ "$pause_nzbget_during_par2repair" -eq 1 ] ; then
        UNPAUSE_NZBGET
    fi

    if [ $par_state -eq 0 ] ; then

        INFO "Repair OK : $parFile"

    else

        ERROR "Repair FAILED : $parFile"
        NMT_FAKEFILE ERR PAR Repair failed
        awk '!/\r/' "$out" | LOGSTREAM ERROR "par2out"
        LOGSTREAM ERROR "par2err" < "$err"

    fi
    rm -f "$err" "$out"
    return $par_state
}

# Return name of current file beg
PAR_OUTPUT_GET_CURRENT_ACTION() {
    # [Scanning: "filename": nn.n%] -> [Scanning: "filename"]
    sed -n '/^[A-Z][a-z]*:/ s/": [^"]*$//p'
}
PAR_OUTPUT_GET_CURRENT_PERCENTAGE() {
    # [Repairing: "filename": nn.n%] -> [nnn] (ie 000 to 1000 )
    sed -n '/^Repairing:/ s/^.*": //;s/[^0-9]*//gp'
}

#Get the last line from Par output. Each line may have many <CR>. 
#we need the text between the last two <CR>s on the last line.
PAR_OUTPUT_GET_LAST_LINE() {
    outfile=$1
    awk 'END { 
            gsub(/\r$/,"") ;        #remove last CR 
            gsub(/.*\r/,"") ;       #Strip all text
            print;
        }' "$outfile"
}
PAR_MONITOR() {
    outfile=$1
    pid=$2
    percent_old=
    scanning_old=""
    loggedParStats=0
    gap=0
    eta=0
    initial_poll=10
    scan_poll=10
    short_repair_poll=20 #seconds
    long_repair_poll=600 #seconds
    poll_time=$initial_poll
    bad_eta_count=0
    DEBUG "PAR_MONITOR"
    touch "$outfile"
    while true ; do
        sleep $poll_time
        if [ ! -f "$outfile" ] ; then break ; fi
        if [ ! -d "/proc/$pid" ] ; then break ; fi # Parent process gone?
        line=$(PAR_OUTPUT_GET_LAST_LINE "$outfile")
        case "$line" in
            Repairing:*)
            #Get percentage nn.m% and convert to nnm
            percent_new=$(echo "$line" | PAR_OUTPUT_GET_CURRENT_PERCENTAGE)
            if [ -n "$percent_new" ] ; then
                gap=$(( $gap + $poll_time ))
                DEBUG "$percent_old - $percent_new after $gap secs"
                if [ -n "$percent_old" -a "$percent_old" -ne $percent_new ] ; then

                    if [ $loggedParStats -eq 0 ]; then
                        loggedParStats=1
                        awk '!/\r/' "$outfile" | LOGSTREAM DEBUG "par2out"
                    fi

                    eta=$(( (1000-$percent_new)*$gap/($percent_new-$percent_old) ))

                    if [ $eta -lt 60 ] ; then
                        eta_text="${eta}s"
                    else
                        eta_text="$(( $eta/60 ))m $(( $eta % 60 ))s"
                    fi

                    msg="Par repair will complete in approx. $eta_text"
                    if [ $unpak_maximum_par_repair_minutes -gt 0 -a  $eta -gt $(( $unpak_maximum_par_repair_minutes * 60 )) ] ; then
                        msg="$msg ( limit is ${unpak_maximum_par_repair_minutes}m )"
                        if [ $bad_eta_count -le 1 ] ; then
                            WARNING "$msg"
                            bad_eta_count=$(( $bad_eta_count + 1 ))
                        else
                            ERROR "$msg"
                            p2pid=$(PAR2_GETPID)
                            if [ -n "$p2pid" ] ; then
                                NMT_FAKEFILE "ERR PAR Aborted too long"
                                kill $p2pid
                                break
                            fi
                        fi

                    else
                        INFO "$msg"
                    fi


                    CLEAR_FAKEFILES repair
                    NMT_FAKEFILE "INFO PAR repair $eta_text left"
                    gap=0
                fi
                percent_old=$percent_new
            fi
            #Once we have got an eta  , adjust the reporting interval 
            # if par2repair looks like it is going to be a while
            poll_time=$(( $eta / 20 ))
            if [ $poll_time -lt $short_repair_poll ] ; then poll_time=$short_repair_poll ; fi
            if [ $poll_time -gt $long_repair_poll ] ; then poll_time=$long_repair_poll ; fi

            ;;
        *)  # Show General Par action. Some lines will be skipped due to polling
            par_action_new=$(echo "$line" | PAR_OUTPUT_GET_CURRENT_ACTION)
            if [ -n "$par_action_new" ] ; then
                poll_time=$scan_poll
                if [ "$par_action_new" != "$scanning_old" ] ; then
                    INFO "PAR repair $par_action_new"
                    CLEAR_FAKEFILES repair
                    NMT_FAKEFILE "INFO PAR repair $par_action_new"
                    scanning_old="$par_action_new"
                fi
            fi
        esac
    done
    CLEAR_FAKEFILES repair
}

#If a par2 process will take too long we want to kill it.
#We could use killall but this may kill other par processes.
#Not sure how to find the 'process group' with limited environment.
#One way to identify the correct one may be to look in /proc/*/
#Works on Linux only
PAR2_GETPID() {

    for pid in /proc/[0-9]* ; do
        if [ "$pid/cwd" -ef "$PWD" -a "$pid/exe" -ef "$unpak_par2_bin" ] ; then
            echo "$pid" | sed 's;/proc/;;'
            break
        fi
    done
}

#####################################################################
# SECTION: UNRAR
#####################################################################
unrar_tmp_dir="unrar.tmp.dir"
UNRAR_ALL() {
    loop=1
    INFO "Unrar all files"
    CLEAR_FAKEFILES UNRAR
    if [ "$unpak_pause_nzbget_during_unrar" -eq 1 ] ; then
        PAUSE_NZBGET
    fi
    failed=0


    while [ $failed -eq 0 -a $loop -le $unpak_nested_unrar_depth ] ; do
        INFO "UNRAR-PASS $loop"
        # Exclude rars matching part[0-9]*[02-9].rar or 
        # part[0-9]*[1-9][0-9]*1.rar (ie end in 1.rar but not 0*1.rar ) 
        if find . -name \*.rar  2>/dev/null | sed 's;^\./;;' |\
           grep -v '[._]part[0-9]*\([1-9][0-9]*1\|[02-9]\)\.rar$' > "$gTmpFile.unrar" ; then
            while IFS= read rarfile ; do
                if ! UNRAR_ONE "$rarfile" ; then
                    gUnrarState="Failed"
                    if [ "$gPass" -eq 1 ] ; then
                        #no point in trying any more until we get all pars.
                        failed=1
                        break
                    fi
                fi
            done < "$gTmpFile.unrar"
        fi
        rm -f "$gTmpFile.unrar"

        loop=$(($loop+1))
    done
    DEBUG "Done STEPS"
    # Unpause NZBGet
    if [ "$unpak_pause_nzbget_during_unrar" -eq 1 ] ; then
        UNPAUSE_NZBGET
    fi

    if ! CHECK_UNRAR_STATE ; then
        gUnrarState="Failed"
    fi

    if [ "$gUnrarState" = "OK" ] ; then
        TIDY_RAR_FILES
        TIDY_NONRAR_FILES
        return 0
    else
        ERROR "UNRAR_ALL FAILED"
        return 1
    fi
}

#If some top level rars are untouched then there are also missing start volumes
CHECK_UNRAR_STATE() {
    if [ -f "$rar_state_list" ] ; then
        if egrep '(FAILED|UNKNOWN)' "$rar_state_list" > $gTmpFile.state  ;  then
            LOGSTREAM ERROR "finalstate"  < $gTmpFile.state
            rm -f $gTmpFile.state
            return 1
        fi
    fi
    rm -f $gTmpFile.state
    return 0
}

#This will do a quick sanity test for missing rar parts.
#It checks number of expect parts and file size and the rar volume headers.
#The main advantage of doing this check is when no par files are present. This will
#check for missing volume files, and also if a rar is corrupted prior to being uploaded,
#then it may catch some simple header errors.
#Note if nzbget is in direct write mode then the file space is pre-allocated and the
# file sizes will be correct regardless of content.
RAR_SANITY_CHECK() {

    rarfile="$1"
    result=0
    size=$(ls -l "$rarfile" | awk '{print $5}')
    INFO "Checking : $rarfile"
    DEBUG RAR CHECK BEGIN $(date)
    wrong_size_count=0
    bname=$(RARNAME "$rarfile")
    num_actual_parts=$(ls -d "$bname"* | RARNAME_FILTER_WITH_PREFIX "$bname" | LINE_COUNT)
    case "$rarfile" in
        *[._]part*.rar) 
            last_part=$(ls "$bname"[._]part*.rar | grep '[._]part[0-9]*\.rar$'| LAST_LINE)
            num_expected_parts=$(echo "$last_part" | sed 's/.*[._]part0*\([0-9]*\)\.rar$/\1/')
            if [ "$nzbget_DirectWrite" != "yes" ] ; then
                wrong_size_count=$(ls -l "$bname"[._]part*.rar | WRONG_SIZE_COUNT $size )
            fi
            if ! ( ls "$bname"[._]part*.rar | CHECK_PARTS ) ; then
                result=1
            fi

            ;;
        *.rar)
            #num_actual_parts=$(ls "$bname.rar" "$bname".r[0-9][0-9] 2>/dev/null | LINE_COUNT)
            if [ $num_actual_parts -eq 1 ] ; then
                last_part="$rarfile"
                num_expected_parts=1
                wrong_size_count=0
            else
                last_part=$(ls "$bname".r[0-9][0-9] 2>/dev/null | LAST_LINE)
                num_expected_parts=$(($(echo "$last_part" | sed 's/.*\.r0*\([0-9][0-9]*\)/\1/')+2))
                if [ "$nzbget_DirectWrite" != "yes" ] ; then
                    wrong_size_count=$(ls -l "$bname".r[0-9][0-9] 2>/dev/null | WRONG_SIZE_COUNT  $size)
                fi
            fi
            if ! ( ls "$bname.rar" "$bname".r[0-9][0-9] 2>/dev/null | CHECK_PARTS ) ; then
                result=1
            fi

            ;;
        *)
            WARNING unknown file $rarfile
            return 1
            ;;
        esac

        DEBUG RAR CHECK END $(date)
        DEBUG RAR CHECK num_actual_parts $num_actual_parts num_expected_parts $num_expected_parts wrong_size_count $wrong_size_count

        if [ "$num_expected_parts" != "$num_actual_parts" ] ; then
            ERROR Missing parts for $rarfile
            NMT_FAKEFILE ERR UNRAR Missing parts for $rarfile
            result=1
        fi
        if ! CHECK_LAST_RAR_PART "$last_part"  ; then
            ERROR End parts missing for $rarfile
            NMT_FAKEFILE ERR UNRAR End parts missing for $rarfile
            result=1
        fi
        if [ "$wrong_size_count" -ne 0 ] ; then
            ERROR Unexpected size for parts of $rarfile
            NMT_FAKEFILE ERR UNRAR Unexpected size for parts of $rarfile
            result=1
        fi

        if [ $(( $size * $num_actual_parts / 1024 )) -ge `FREE_KB "."` ] ; then
            ERROR "Low Disk space `FREE_KB` Remaining"
            NMT_FAKEFILE ERR UNRAR Low Disk Space
            result=1
        fi

        return $result
}

# Do a quick header check on each part.
CHECK_PARTS() {

        header=0
        while IFS= read part ; do
            if ! CHECK_HEADER "$part" ; then
                header=1
                break
            fi
        done
        if [ $header -eq 1 ] ; then 
            NMT_FAKEFILE ERR "UNRAR Header errors"
        fi
        [ $header -eq 0  ]
}

# $1 = rar file
CHECK_HEADER() {
    INFO Checking header for "$1"
    if  "$unpak_unrar_bin" lb "$1" > $gTmpFile.rar_hdr ; then
        if [ ! -s $gTmpFile.rar_hdr ] ; then
            ERROR Archive Error for "$1"
            header=1
        fi
    else
        ERROR Archive Error for "$1"
        header=1
    fi
    rm -f $gTmpFile.rar_hdr
}


#Takes ls -l of rar parts as input and returns number of parts with unexpected size.
WRONG_SIZE_COUNT() {
    size=$1
    ALL_BUT_LAST_LINE | awk '$5 != '$size' {print $5}' | LINE_COUNT
}

#If the last file is missing the 'num_expected_parts' will be wrong, so list the 
#contents of the last part and check it is either '100%' or '<--'
CHECK_LAST_RAR_PART() {
    count=$("$unpak_unrar_bin" vl "$1" | LINE_COUNT)
    code=$("$unpak_unrar_bin" vl "$1" | awk 'NR == '$count'-3 { print $3 }')
    [ "$code" != "-->" -a "$code" != "<->" ]
}

UNRAR_ONE() {
    
    tmplog="unpak.rar.out.$$" 
    tmperrlog="unpak.rar.err.$$" 
    rarfile="$1"
    if [ -e "$rarfile" ] ; then
        #We only change the state of rar's whose state is already set.
        #These will be top level rars only. Nested rar's do not exist when the 
        #state list is being populated.
        #This ensures that the par-repair stage is only called if  a top-level unrar fails.
        state=$(GET_RAR_STATE "$rarfile")

        DEBUG "RARFILE $rarfile STATE = $state global state = $gUnrarState"
        if [ "$state" = "UNKNOWN" -o "$state" = "REPAIRED" -o "$state" = "" ] ; then
            #Perform additional checks if nzbget did not do any parchecking.
            if [ "$arg_par_check" -eq 0 ] ; then
                if [ $unpak_sanity_check_rar_files -eq 1 ] ; then
                    if ! RAR_SANITY_CHECK "$rarfile" ; then
                        # Only set top level RARs as failed. (by using CHANGE_RAR_STATE not SET_RAR_STATE)
                        CHANGE_RAR_STATE "$rarfile" "FAILED"
                        return 1
                    fi
                fi
            fi
            INFO "Extracting : $1"
            set +e
            d=$(DIRNAME "$rarfile")
            r=$(BASENAME "$rarfile" "")

            #To avoid overlap issues every rar must unpack to a different local folder.
            #At the very end of ALL processing we can move all infomation up into the root folder.
            #
            # This complexity is needed if for example we have a.rar and a.sub.rar(with a.rar(2) inside).
            #
            # if a.sub.rar succeeds it produces a.rar(2) 
            # if a.rar(1) then fails we cannot copy up a.rar(2) yet. We have to keep it down until a.rar(1) is repaired.
            # This means the list of rar states may need to be updated to list rars in nested folders!

            (mkdir -p "$d/$unrar_tmp_dir" && cd "$d/$unrar_tmp_dir" && "$unpak_unrar_bin" x -y -p- "../$r" 2>"../$tmperrlog" |\
                TEE "../$tmplog" |\
                LOGSTREAM INFO "unrar" 
            )
            set -e
            if grep -q '^All OK' "$d/$tmplog" ; then
                INFO "Unrar OK : $rarfile"
                SET_RAR_STATE "$rarfile" "OK"
                ls -l "$d/$unrar_tmp_dir" | LOGSTREAM DEBUG "rarcontents"
                #Extract all lines with filenames from unrar log and add to delete queue
                sed -n "s#^Extracting from ../\(.*\)#$d/\1#p" "$d/$tmplog" >> "$delete_queue"
                rarState=0
            else
                ERROR "Unrar FAILED : $rarfile"
                # Only set top level RARs as failed. (by using CHANGE_RAR_STATE not SET_RAR_STATE)
                CHANGE_RAR_STATE "$rarfile" "FAILED"
                LOGSTREAM ERROR "unrar-err" < "$d/$tmperrlog" 
                NMT_FAKEFILE ERR "UNRAR from $rarfile failed"
                rarState=1
            fi
            rm -f "$d/$tmplog" "$d/$tmperrlog"
            return $rarState
        fi
    fi
}

###############################################################################
# SECTION: UTILS
###############################################################################
FREE_KB() {
    free_space=$(df -k "$1" | awk 'NR==2 {print $4}')
    INFO "Freespace [$1] = $free_space"
    echo "$free_space"
}

#Get last line of stdin 'tail -1'
LAST_LINE() {
    awk 'END { print }'
}

#wc -l
LINE_COUNT() {
    awk 'END { print NR }'
}

ALL_BUT_LAST_LINE() {
    sed 'x;1 d'
}

NZBGET() {
   DEBUG "nzbget $@"
   "$unpak_nzbget_bin" -c "$unpak_nzbget_conf" "$@"
}
PAUSE_NZBGET() { NZBGET -P; }
UNPAUSE_NZBGET() { NZBGET -U; }

GET_NICE_NZBNAME() {
    #The NZBFile is converted to a nice name which is used for the group name in the nzbget list,
    # and also for the folder name (if AppendNzbDir is set)
    #From NZBSource the conversion is (strchr("\\/:*?\"><'\n\r\t", *p) then trailing dots and spaces are removed.
    #The following sed does the same - except for the whitespace
    BASENAME "$arg_nzb_file" .nzb | sed "s#['"'"*?:><\/]#_#g;s/[ .]*$//'
}

quote_re="['"'"]'
rar_re='[._](part[0-9][0-9]*\.rar|rar|r[0-9][0-9])$'

#Same as rarname but remove quotes.
FLAGID() {
    echo "$1" | sed -r "s/$rar_re//;s/$quote_re//g;"
}
#Note. Only top level rars that exist on the first pass have their state stored.
#So we dont need to bother with nested paths.
RARNAME() {
    echo "$1" | sed -r "s/$rar_re//"
}

# /a/b/c.rar -> /a/b/c
# /a/b/c.jpg -> nothing
RARNAME_FILTER() {
    sed -rn "s/$rar_re//p"
}
# An additional string can be inserted to match the basename.
RARNAME_FILTER_WITH_PREFIX() {
    s=$(echo "$1" | RE_ESCAPE_FOR_SED)
    sed -rn "s/^($s)$rar_re/\1/p"
}

#Add '\' to regular expression metacharacters in a string.
#Required so we can search for the string whilst using regualr expressions.
# eg grep "^$string$". this will fail if string contains '[].* etc.
RE_ESCAPE_FOR_SED() {

# fix made for http://apps.sourceforge.net/phpbb/nzbget/viewtopic.php?f=3&t=46&sid=5409e168c0c3666fe8b80127d08d6542#p188

# old setting    sed 's/\([][.*/\]\)/\\\1/g'
    sed 's/\([].[*/\]\)/\\\1g'
}
# Same as RE_ESCAPE_FOR_SED but (|) are also meta characters.
RE_ESCAPE_FOR_GREP() {
# old setting    sed 's/\([][.*/\(|)]\)/\\\1/g'
     sed 's/\([].[*/\(|)]\)/\\\1/g'
}


BASENAME() {
    echo "$1" | sed "s|.*/||;s|$2\$||"
}
DIRNAME() {
    echo "$1" | sed 's|^\([^/.]\)|./\1|;s|\(.\)/[^/]*$|\1|'
}
PRETTY_TEXT() {
    #sed -r 's/[^A-Za-z0-9 /*]+/ /g' | CHANGE_CASE "$unpak_episodes_folder_case"
    sed -r 's/[-:_.* ]+/ /g' | CHANGE_CASE "$unpak_episodes_folder_case"
}

CHANGE_CASE() {
    case "$1" in
        *upper) CHANGE_CASE_AWK toupper ;;
        *lower) CHANGE_CASE_AWK tolower;;
        caps) CHANGE_CASE_AWK caps;;
        *) cat;;
    esac
}

# Input - stdin $1=upper,lower,caps : output : stdout
CHANGE_CASE_AWK() {

    awk '
    function caps(str) {
        if (match(str,/^[a-zA-Z]/)) { 
            return toupper(substr(str, 1, 1))tolower(substr(str, 2))
        } else {
            return substr(str,1,1)toupper(substr(str, 2, 1))tolower(substr(str, 3))
        }
    }

    {
        gsub(/\//,"/ "); 
        for(i=1;i<=NF;i++){
            #Change words that have alphabetic chars only
            #if (match($i,/^[a-zA-Z]+$/)) {
                $i='"$1"'($i)
            #}
        }
        gsub(/\/ /,"/"); 
        print 
    }'
}
# Input $1=field sep + data from std in
# Output 'stdin on one line joined by field sep
FLATTEN() {
    awk '{printf "%s%s" (NR==1?"":"'"$1"'") $0}'
}

# Tee command - borrowed from http://www.gnu.org/manual/gawk/html_node/Tee-Program.html
# 'Arnold Robbins, arnold@gnu.org, Public Domain 'and tweaked a bit.
TEE() {
    awk '
      BEGIN {
          append=(ARGV[1] == "-a")
          for(i=append+1 ; i<ARGC;i++) {
              copy[i]=ARGV[i]
              if (append == 0) printf "" > copy[i];
          }
          ARGC=1; #Force stdin

      }
      { print ; 
        for (i in copy) { 
            print >> copy[i];
        }
        system(""); # Flush all buffers
        #fflush("");
      }
      END { for (i in copy) close(copy[i]) }
      ' "$@"
}
#Special Tee command for nzbget logging. The main command pipes
#its stdout and stderr to TEE_LOGFILES which then sends it to
#1. stdout (to be captured by nzbget)
#2. unpak.txt (local log file)
#3. unpak.html (optional)
TEE_LOGFILES() {
    awk '
      function timestamp() {
        return strftime("%T",systime());
     }
      BEGIN {
          debug='$unpak_debug_mode'
          txt=ARGV[1];
          html="";
          if ( '$unpak_nmt_html_logging' == 1 ) {
              html=ARGV[2];
          }
          ARGC=1; #Force stdin

      }
      {
        v=substr($0,2,4);
        if ( debug==1 || v!="DEBU" ) {
            sub(/\]/,"] unpak:" timestamp());
            print ; 
            print >> txt;
            c="blue";
            if (html != "") {
                if (v=="INFO") {
                    c="green";
                } else if (v == "DETA" ) {
                    c="blue";
                } else if (v == "DEBU" ) {
                    c="blue";
                } else if (v == "WARN" ) {
                    c="orange";
                } else if (v == "ERRO" ) {
                    c="red";
                }
                printf "<br><font \"color=%s\">%s</font>\n",c,$0 >> html;
            }
            system(""); # Flush all buffers
        }
      }
      END { close(txt); if (html != "" ) close(html); }
      ' "$@"
}

#Join files with the format *.nnnn.ext or *.ext.nnnn
JOINFILES() {

    ext="$1"
    extname=$(echo "$ext" | sed -r 's/\.[0-9]+//g') #remove digits from extension
    glob=$(echo "$ext" | sed 's/[0-9]/[0-9]/g')            # glob pattern

    for part in *$ext ; do
        DEBUG "join part $part"
        if [ -f "$part" ] ; then
            bname=$(echo "$part" | sed 's/\.[^.]*\.[^.]*$//') #remove last two extensions
            newname="$bname$extname"
            INFO "Joining $newname"
            if [ -f "$newname" ] ; then
                WARNING "$newname already exists"
            else
                if cat "$bname"$glob > "$newname" ; then
                    rm -f "$bname"$glob
                    #true
                else
                    mv  "$newname" "damaged_$newname"
                fi
            fi
        fi
    done
}

#is $1 a sub directory of $2 ?
IS_SUBDIR() {
    sub=$(cd "$1" ; pwd)
    while [ ! "$sub" -ef "/" ] ; do
        if [ "$2" -ef "$sub" ] ; then
            DEBUG "subdir [$1] [$2] = YES"
            return 0
        fi
        sub=$(cd "$sub/.." ; pwd )
        DEBUG "Subdir = [$sub]" ;
    done
    DEBUG "subdir [$1] [$2] = NO"
    return 1
}

TIDY_RAR_FILES() {
    DEBUG "TIDY_NONRAR_FILES with $gUnrarState"
    if [ "$gUnrarState" = "OK" ] ; then
        if [ "$arg_par_check" -eq 0 -a "$external_par_check" -eq 1 ] ; then
            DELETE_PAUSED_PARS
        fi
        DELETE_RAR_FILES
        MOVE_RAR_CONTENTS .
        CLEAR_ALL_RAR_STATES 0


    else
        #Easier to keep NZB Local
        cp "$arg_nzb_file.queued" .
    fi
}
TIDY_NONRAR_FILES() {
    DEBUG "TIDY_NONRAR_FILES"
    JOINFILES ".0001.ts"
    JOINFILES ".avi.001"
    JOINFILES ".avi.01"
    #rm -f *.nzb *.sfv *.1 _brokenlog.txt *.[pP][aA][rR]2 *.queued 
    rm -f *.nzb *.sfv *.1 _brokenlog.txt *.[pP][aA][rR]2 *.queued 
    if [ "$unpak_rename_img_to_iso" -eq 1 ] ; then
        ls *.img 2>/dev/null | EXEC_FILE_LIST "mv '\1' '\1.iso'" ""
    fi
    TIDY_NZB_FILES
}

#Rename nzb.queued to nzb$finished_nzb_ext then delete any old *$finished_nzb_ext files.
TIDY_NZB_FILES() {
    mv "$arg_nzb_file.queued" "$arg_nzb_file$finished_nzb_ext"
    if [ $unpak_max_nzbfile_age -gt 0 ] ; then
        #-exec switch doesnt seem to work
        d=$(DIRNAME "$arg_nzb_file")
        INFO Deleting NZBs older than $unpak_max_nzbfile_age days from $d
        find "$d" -name \*$finished_nzb_ext -mtime +$unpak_max_nzbfile_age > $gTmpFile.nzb
        LOGSTREAM INFO "old nzb" < $gTmpFile.nzb
        sed "s/^/rm '/;s/$/'/" $gTmpFile.nzb | sh
        rm -f $gTmpFile.nzb
    fi
}

#Notification of changes to unpak.sh.
VERSION_CHECK() {
    if [ "$unpak_check_for_new_versions" -eq 1 ] ; then
        latest=$(wget -O- http://www.prodynamic.co.uk/nzbget/unpak.version 2>/dev/null)
        if [ -n "$latest" -a "$latest" != "$VERSION" ] ; then
            INFO "Version $latest is available (current = $VERSION )"
            #NMT_FAKEFILE INFO "unpak version $latest is available"
        fi
    fi
}

#Create a fake media file whose name indicates some kind of error has occured.
#This makes it easier to differentiate between empty folders whose contents are
#still being processed.
NMT_FAKEFILE() {
    m=$(echo "$*" | sed 's;[/\];;g')
    if [ "$unpak_nmt_alert_using_fake_files" -eq 1 ] ; then
        for ext in $unpak_nmt_fake_file_extensions ; do
            touch "UnpacK._$*_$ext"
        done
    fi
}
CLEAR_FAKEFILES() {
    for ext in $unpak_nmt_fake_file_extensions ; do
        rm -f UnpacK._*"$1"*_$ext
    done
}
CLEAR_TMPFILES() {
    rm -f /tmp/unpak.[0-9]*.*
}

#Store the state of each rar file.
# This is simply in a flat file with format
# id*STATE
# where id is the id based on the basename of the rar file  and
# state is its current state.
#
# If a rar file has no state it was likely extracted from inside another rar file.
# as all of the initial states are set prior to extraction. This means that at least
# one volume of a rar file must be present for it to be correctly registered.
#
# STATE   | Next Action | Next States   | Comment
# none    | UNRAR       |   none        | this could be a rar created from another rar file
# UNKNOWN | UNRAR       | OK,FAILED     | this is a top-level rar identified from any one of its parts
# OK      | All Done    |     -         | Sucess.Keep the state to avoid re-visiting when nested unpacking.
# FAILED  | par fix.    |REPAIRED,FAILED| State will stay failed. 
# REPAIRED| UNRAR       | OK,FAILED     |
# 
rar_state_list="unpak.state.db"
rar_state_sep="*" #Some char unlikely to appear in filenames. but not quotes. E.g. * : / \
delete_queue="unpak.delete.sh"

GET_RAR_STATE() {
    r=$(FLAGID "$1")
    [ ! -f $rar_state_list ] || awk "-F$rar_state_sep" '$1 == "'"$r"'" {print $2}' $rar_state_list
}
#Change if it already exists
CHANGE_RAR_STATE() {
    r=$(FLAGID "$1")
    s="$2"
    touch "$rar_state_list"
    awk "-F$rar_state_sep" '{ if ( $1=="'"$r"'" ) { print $1"'"$rar_state_sep$s"'" } else { print }}' $rar_state_list > $rar_state_list.1 &&\
    mv $rar_state_list.1 $rar_state_list
}
SET_RAR_STATE() {
    r=$(FLAGID "$1")
    s="$2"
    DEBUG "FLAGID [$1]=[$r]"
    touch "$rar_state_list"
    awk "-F$rar_state_sep" '{ if ( $1 != "'"$r"'" ) { print }} END { print "'"$r$rar_state_sep$s"'" } ' $rar_state_list > $rar_state_list.1 &&\
    mv $rar_state_list.1 $rar_state_list
    DEBUG "SET RARSTATE [$r]=[$s]"
}

LIST_RAR_STATES() {
    state_pattern="$1"
    touch "$rar_state_list"
    awk "-F$rar_state_sep" '{ if ( $2 ~ "'"$state_pattern"'" ) { print $1 }}' $rar_state_list
}

#The script is rar-driven (we may not have downloaded any pars yet and unrar before looking at pars)
#However, the initial rar file may be missing. So we need to look at all rar files present to 
#know the state of rar files.
#The only situation we cant manage is where there are no rar parts at all. Unlikely.


INIT_ALL_RAR_STATES() {
    CLEAR_ALL_RAR_STATES 1
    lastPart=

    # Initialise the rar state file. This consist of each rar archive name
    # in the top level directory followed by '*UNKNOWN' (ie state is unknown)
    # There is one entry per multi-volume archive.
    # There are only entries if volumes are present at the start of processing.
    ls | awk '
    BEGIN {last_flag=""}
    {
    if (sub(/'"$rar_re"'/,"")) {
        gsub(/['"$quote_re"']/,"") #REMOVE quotes to get FLAGID
        flag=$0
        if (flag != last_flag) {
            print flag "'$rar_state_sep'UNKNOWN"
            last_flag = flag
        }
    }}' > "$rar_state_list"
    
    LOGSTREAM DEBUG "init" < "$rar_state_list"
}

#We have to unpack each rar in its own folder to avoid clashes.
#This function should be called right at the end to push everything up
#to the main folder.

MOVE_RAR_CONTENTS() {

    #INFO "Move rar contents into $1 = $(pwd)"
    if [ -d "$unrar_tmp_dir" ]; then 
        DEBUG "Moving rar contents up from [$PWD/$unrar_tmp_dir]"
        ( cd "$unrar_tmp_dir"; MOVE_RAR_CONTENTS "../$1" )
        #Copy directory up. 
        #
        # could use mv $unrar_tmp_dir/* . but two problems.
        #
        # Hidden files and 
        # mv with globbing will return an error if no files match.
        #But we dont really mind that, we only want an error if there was
        #a problem actually moving a real file.
        # 
        ls -A "$unrar_tmp_dir" | EXEC_FILE_LIST "mv '$unrar_tmp_dir/\1' ." -e
        rmdir "$unrar_tmp_dir"
    fi
}


DELETE_RAR_FILES() {
    if [ -f "$delete_queue" ] ; then
        if [ $unpak_delete_rar_files -eq 1 ] ; then
            EXEC_FILE_LIST "rm '\1'" "-e" < "$delete_queue"
        else
            mv "$delete_queue" "$delete_queue.bak"
        fi
    fi
    rm -f "$delete_queue"
}

CLEAR_ALL_RAR_STATES() {
    force=$1
    if [ "$force" -eq 1 -o $unpak_debug_mode -eq 0 ] ; then
        rm -f "$rar_state_list"
    fi
}

LOG_ARGS() {
    cmd="'$0'"
    for i in "$@" ; do
        cmd="$cmd '$i' "
    done
    INFO "ARGS: $cmd"
}

#If the unpak_episodes_folder_case option is selected rename existing folders.
# This function needs fixing but it's only really for people that want to move all
#of thier folders from one caps format to another
#It doesnt do the movie folder.
RENAME_EXISTING_EPISODE_FOLDERS() {
    DEBUG "BEGIN Episode Folder Rename"
    if [ "$unpak_rename_existing_episode_folders" -eq 1 ] ; then
        case "$unpak_episodes_folder_case" in
            lower|upper|caps)
                tv_root=$(DIRNAME "$(CREATE_CATEGORY_PATH 'Tv')")
                tv_new_name=$(echo "tv" | CHANGE_CASE "$unpak_episodes_folder_case" )
                for t in TV Tv tV tv ; do
                    RENAME_EXISTING_EPISODE_SUB_FOLDERS "$tv_root" "$t" "$tv_new_name"
                done
            ;;
            *) ;;
        esac
    fi
    DEBUG "END Episode Folder Rename"
}

# $1=root $2=oldname $3=new name
RENAME_EXISTING_EPISODE_SUB_FOLDERS() {
    if [ -d "$1/$2" ] ; then 

        ls -AF "$1/$2" | grep '/' | while IFS= read tv_path ; do
            #if [ -d "$1/$2/$tv_path" ] ; then
                tv_path_new=$(echo "$tv_path" | CHANGE_CASE "$unpak_episodes_folder_case" )
                RENAME_EXISTING_EPISODE_SUB_FOLDERS "$1/$2" "$tv_path" "$tv_path_new"
            #fi
        done
        #DEBUG "Renaming Episode Folder [$1/$2] -> [$1/$3]"
        MERGE_FOLDERS "$1/$2" "$1/$3" > /dev/null
        #DEBUG "DONE Renaming Episode Folder [$1/$2] -> [$1/$3]"
    fi
}

#Move command that merges non-empty directories.
#$1=source
#$2=dest
#stdout = list of moved files. 
MERGE_FOLDERS() {
    if [ ! "$1" -ef "$2" ] ; then
        DEBUG "MERGE CONTENTS [$1]->[$2]"
        if [ ! -e "$2" ] ; then
            mkdir -p "$2"
        fi
        ls -A "$1" | while IFS= read f ; do
            if [ -d "$1/$f" ] ;then
                if [ -e "$2/$f" ] ; then
                    MERGE_FOLDERS "$1/$f" "$2/$f"
                else
                    DEBUG "MVD [$1/$f] [$2/.]"
                    mv "$1/$f" "$2/."
                fi
            else
                DEBUG "MVF [$1/$f] [$2/.]"
                rm -f "$2/$f"
                mv "$1/$f" "$2/."
                echo "$2/$f" #output
            fi
        done
        rmdir "$1"
        DEBUG "END MERGE CONTENTS [$1]->[$2]"
    fi
}

#Stdout = new category
#If category ends in '*' then the folder contents are moved, otherwise
#the download folder itself is moved into the category folder.
AUTO_CATEGORY() {

    cat_from_files=$(AUTO_CATEGORY_FROM_FOLDER)
    DEBUG "autocategory cat_from_files=[$cat_from_files]"
    cat="$cat_from_files"

    cat_from_nzb=$(AUTO_CATEGORY_FROM_NEWSGROUPS_INSIDE_NZB)
    DEBUG "autocategory cat_from_nzb=[$cat_from_nzb]"

    # Try to get category from newsgroups embedded in the nzb
    if [ -z "$cat" ] ; then
        cat="$cat_from_nzb"
    else
        #Make sure PIN:FOLDER takes priority
        case "$cat_from_nzb" in 
            $unpak_nmt_pin_flag*) cat="$cat_from_nzb" ;;
        esac
    fi
    DEBUG "autocategory check nfo cat=[$cat]"

    if [ -z "$cat" ] ; then
        cat=$(AUTO_CATEGORY_FROM_IMDB)
    fi
    DEBUG "autocategory: check pin cat=[$cat]"

    cat=$(NMT_SUBSTITUTE_PIN_FOLDER "$cat")

    #If the categoty is not a full path then make it pretty
    #but if it's empty make it the default category.
    case "$cat" in
        /*) true ;;
        ?*) cat=$(echo "$cat" | PRETTY_TEXT) ;;
        *) cat="$unpak_category_default" ;;
    esac

    if [ $unpak_episodes_in_same_folder -eq 1 ] ; then
        if echo "$cat" | grep -iq '^Tv/' ; then
            #Note asterisk on the end means copy individual files into category not the entire folder.
            cat="$cat$flatten"
        fi
    fi
    DEBUG "autocategory final: cat=[$cat]"
    echo "$cat"
}

AUTO_CATEGORY_FROM_IMDB() {
    if [ "$unpak_auto_categorisation_from_imdb" -ne 1 ] ; then return 0 ; fi
    imdb_url=`IMDB_EXTRACT_LINK_FROM_NFO`
    if [ -n "$imdb_url" ] ; then
        DEBUG "IMDB URL [$imdb_url]"
        imdb_page="$gTmpFile.imdb"
        wget -O "$imdb_page" "$imdb_url"
        title=$(IMDB_EXTRACT_TITLE "$imdb_url" "$imdb_page")
        DEBUG "IMDB title = [$title]"
        if IMDB_ISMOVIE "$imdb_page" ; then
            original_folder_name=`BASENAME "$arg_download_dir" "" | PRETTY_TEXT`

            folder="$unpak_imdb_movie_format"

            cert=$(IMDB_GET_CERTIFICATES "$imdb_page" )
            REPLACE_TOKEN folder CERT "$cert"

            DEBUG "folder after cert = [$folder]"

            REPLACE_TOKEN folder TITLE "$title"
            DEBUG "folder after title = [$folder]"

            genre=$(IMDB_GET_GENRES < "$imdb_page" | FLATTEN "-" )
            REPLACE_TOKEN folder GENRE_LIST "$genre"
            DEBUG "folder after genre = [$folder]"

            REPLACE_TOKEN folder NZB "$original_folder_name"
            DEBUG "folder after nzb = [$folder]"

            if [ -z "$folder" ] ; then
                folder="$original_folder_name"
            fi

            echo "Movies/$folder$flatten"

        else
            echo "Tv/$title"
        fi
        rm -f "$imdb_page"
    fi
}

# Replace %..TOKEN..% with the token value.
# Characters between % and token are only replaced if token is not empty.
REPLACE_TOKEN() {
    name="$1"
    eval "old=\$$1"
    token="$2"
    new="$3"
    DEBUG "BEGIN TOKEN name=[$name] old=[$old] token=[$token] new=[$new]"
    eval "DEBUG $name=[\$$name]"
    case "$old" in
        *$token*)
        if [ -n "$new" ] ; then
                new=$(echo "$old" | sed -r "s/\{([^{]*)$token([^}]*)\}/\1$new\2/g")
        else
                new=$(echo "$old" | sed -r "s/\{([^{]*)$token([^}]*)\}//g")
        fi
        eval "$name=\$new"
        ;;
    esac
    DEBUG "TOKEN name=[$name] old=[$old] token=[$token] new=[$new]"
    eval "DEBUG $name=[\$$name]"
}
APPEND() {
    # concatenate with optional space. ie. var=$var${var:+ }$text
    DEBUG "APPEND [$1][$2]"
    eval $1="\$$1\${$1:+ }'$2'"
}

AUTO_CATEGORY_FROM_FOLDER() {
    # Try to extract series.
    # Used to match series and episode were there is a 'S' or 'E' designator
    # Will look in 3 places: 
    # 1. Inside *.nfo (Often the best file name is in here)
    # 2. Name of the folder
    # 3. Names of the media files
    #
    # It looking mainly for TV program format, in oder of preference .
    # s01e01 / s2d2
    # 1x1
    # 101

    if [ "$unpak_auto_categorisation_from_filenames" -ne 1 ] ; then return 0 ; fi

    cat=

    DEBUG "check 1 cat=[$cat]"
    cat=`AUTO_CATEGORY_FROM_FILENAMES_SERIES "S01E01"`

    DEBUG "check 2 cat=[$cat]"
    if [ -z "$cat" ] ; then
        cat=`AUTO_CATEGORY_FROM_FILENAMES_SERIES "1x01"`
    fi
    DEBUG "check 3 cat=[$cat]"
    if [ -z "$cat" ] ; then
        cat=`AUTO_CATEGORY_FROM_FILENAMES_SERIES "101" `
    fi
    DEBUG "check 4 cat=[$cat]"

    if [ -z "$cat" ] ; then
        if ls . * | egrep -iq '\.(mp3|flac|wma|wav|ogg)$' ; then cat="Music" ; fi
    fi
    DEBUG "check 5 cat=[$cat]"

    if [ -z "$cat" ] ; then
        if ls . * | egrep -iq '\.(exe)$' ; then cat="Software" ; fi
    fi
    DEBUG "check 6 cat=[$cat]"
    echo "$cat"
}

# Try to match a TV series type name. s01e01 s1d1 etc.
# $1 = re to match name
# $2 = re to match series
# $3 = re to skip non-interesting characters.
# output = Series Category or ''
AUTO_CATEGORY_FROM_FILENAMES_SERIES() {

    mode="$1"

    #Match 1 or 2 digit series or episode. USed when a prefix is given eg S05 or E3
    n="([0-9]{1,2})"

    #Used to match series when no prefix is present. eg 704 = S07e04.
    # or 1103 = series 11 episode 3. 
    #Match 0n , n , or nn except 19 and 20 - as these are often century eg [20]08
    #if there is a s20e08 then hope it has prefix!
    #LastOfTheSummerWine is on Season 29!
    #Our max season will be 40.
    nbare="([1-9]|0[1-9]|1[0-8]|2[1-9]|[34][0-9])" 

    #Match 2 digit episode - used when the is no prefix. 
    n2="([0-9]{2})"

    c="0-9a-zA-Z"
    skip="[^$c]"
    keep="[$c]"
    noSpace="[^ ]"

    case "$mode" in 
        S01E01)
        series="$skip+[sS]$n[dDeE]$n$skip"
        seriesNoSpace="$noSpace+[sS]$n[dDeE]$n$skip"
        ;;

        1x01)
        series="$skip+$n[xX]$n$skip"
        seriesNoSpace="$noSpace+$n[xX]$n$skip"
        ;;

        101)
        series="$skip+$nbare$n2$skip"
        seriesNoSpace="$noSpace+$nbare$n2$skip"
        ;;
        *) exit 1;;
    esac

    nameIncSpace="$skip*($keep[^:]*$keep)"
    nameNoSpace="$.*($keep[^ :]*$keep)"
    nfo_pattern="$nameNoSpace$seriesNoSpace"
    nzb_pattern="$nameIncSpace$series"
    media_pattern="$nameIncSpace$series.*\.(avi|AVI|mkv|MKV|nfo|NFO)$"

    extract_from_nfo_name=
    if [ "$mode" != 101 ] ; then
        extract_from_nfo_name=$(cat *.nfo 2>/dev/null | sed -rn "/$nfo_pattern/ p")
    fi
    extract_from_nzb_name=$(echo "$NZB_NICE_NAME-" | sed -rn "/$nzb_pattern/ p")
    extract_from_media_name=$(ls | sed -rn "/$media_pattern/ p" | head -1)
    if [ -n "$extract_from_nfo_name" ] ; then
        nameAndSeries="$nameNoSpace$seriesNoSpace"
        cat="$extract_from_nfo_name"
        INFO "Getting category from NFO filename [$cat] using [$nameAndSeries]"
    else
        nameAndSeries="$nameIncSpace$series"
        if [ -n "$extract_from_nzb_name" ] ; then
            cat="$extract_from_nzb_name"
            INFO "Getting category from NZB filename [$cat] using [$nameAndSeries]"
        else
            if [ -n "$extract_from_media_name" ] ; then
                cat="$extract_from_media_name"
                INFO "Getting category from media filenames [$cat] using [$series]"
            fi
        fi
    fi

    if [ -n "$cat" ] ; then
        sub_reqid="s/.*$skip([Pp][Rr][Ee][Ss][Ee][Nn][Tt][Ss]$skip*|[Rr][Ee][Qq]$skip*|#)[0-9]{5}//"
        sub_reqtxt="s/.*$skip+[Rr][Ee][Qq]$skip//"
        sub_leading_zeros="s/([^1-9]|^)0+([1-9])/\1\2/g"

        #Convert 'blah REQ blah 12345 the.fonZ - s01e02' to 'tv/the fonZ/s1'  
        # Series = \2
        # Episode = \3

        cat=$(echo "$cat" | sed -r  "$sub_reqid;$sub_reqtxt;s@$nameAndSeries.*@Tv/\1/Series \2@;$sub_leading_zeros")

        
    fi
    DEBUG "cat=[$cat] using series=[$series]"
    echo "$cat"
}
AUTO_CATEGORY_FROM_NEWSGROUPS_INSIDE_NZB() {
    if [ "$unpak_auto_categorisation_from_newsgroups" -ne 1 ] ; then return 0 ; fi
    #Get values of all subfolder_by_newsgroup_ variables.
    set | sed -n '/^unpak_subfolder_by_newsgroup_[0-9]/ s/^[^=]*=//p' | sed "s/^' *//g;s/ *: */=/;s/ *'$//g" |\
        while IFS== read keyword destination ; do
            DEBUG "Check category $keyword=$destination"
            if grep -ql "<group>.*$keyword.*</group>" "$arg_nzb_file$finished_nzb_ext" ; then
                INFO "Getting category from newsgroup matching [$keyword]"
                echo "$destination"
                break
            fi
        done
}

CREATE_CATEGORY_PATH() {
    case "$1" in
        /*) new_path="$1" ;;
        *) new_path="$unpak_completed_dir/$1" ;;
    esac
    CREATE_FOLDER_RELATIVE_TO_DESTDIR "$new_path"
}

#cat = final location*Category
#Also changes directory so must not be run from subprocess.
RELOCATE() {
    cat="$arg_category"
    move_folder=1
    DEBUG "1 move_folder=[$move_folder] cat=[$cat]"
    if [ -z "$cat" -a $unpak_auto_categorisation -eq 1 ] ; then
        cat=$(AUTO_CATEGORY)
        DEBUG "2a cat=[$cat]"
        case "$cat" in 
           *$flatten) cat=`echo "$cat" | sed "s/$flatten\$//"`
                DEBUG "2 move_folder=[$move_folder]"
                move_folder=0
               ;;
       esac
    fi
    DEBUG "3 move_folder=[$move_folder] cat=[$cat]"

    RENAME_EXISTING_EPISODE_FOLDERS

    new_path=$(CREATE_CATEGORY_PATH "$cat")

    b=$(BASENAME "$arg_download_dir" "")

    if [ ! "$new_path/$b" -ef "$arg_download_dir" ] ; then

        INFO "Moving $arg_download_dir to $new_path/. [Category=$cat]"

        DEBUG "4 move_folder=[$move_folder]"
        if [ "$move_folder" -eq 1 ] ; then
            new_path=$( GET_NEW_FOLDER_NAME "$new_path" "$b" )
            DEBUG "new_path= [$new_path]"
            mkdir -p "$new_path"
        fi

        #If unpak_nmt_pin_folder_scrample_windows_share is set then add an asterisk to the
        #folder name, if it is going in the pin_root folder. This will force samba to
        #use an alternate name, so may help avoid inadvertent viewing.
        #Again this is no replacement for real security.
        if [ "$unpak_nmt_pin_folder_scrample_windows_share" -eq 1 ]; then
            if IS_SUBDIR "$new_path" "$unpak_nmt_pin_root" ; then
                mv "$new_path" "$new_path:"
                new_path="$new_path:"
            fi
        fi

        # The output is used later to update the 'RECENT' folders.
        MERGE_FOLDERS "$arg_download_dir" "$new_path" > $gTmpFile.moved_files
        cd "$new_path"
    fi
    INFO "Relocated cat=[$cat] cwd=[$PWD]"
}

#$1=root $2=folder
GET_NEW_FOLDER_NAME() {
    #Move entire folder but rename if there is a clash TODO : TEST
    if [ -d "$1/$2" ] ; then
        loop=1
        while [ -d "$1/$2.$loop" ] ; do
            loop=$(( $loop + 1 ))
        done
        echo "$1/$2.$loop"
    else
        echo "$1/$2"
    fi
}

#Input = $1=imdb page
#Output = Return status 0=tv 1=not tv
IMDB_ISTV() {
    grep -ql 'episodes#season-1' "$1"
}

#Input = $1=imdb page
#Output = Return status 0=movie 1=not movie
IMDB_ISMOVIE() {
    if IMDB_ISTV "$1" ; then
        INFO ISTV
        return 1
    else
        return 0
    fi
}

#Input  $1=main imdb url $2=html text of main url 
#Output = Title of film according to $unpak_imdb_title_country_filter
IMDB_EXTRACT_TITLE() {
    if grep -q 'releaseinfo#akas' "$2" ; then
        #Get the title using the AKA page
        IMDB_EXTRACT_AKA_TITLE "$1" "$unpak_imdb_title_country_filter" | grep -v "^DBG:"
    else
        #Get the title from main page
        grep '<title>' "$2" | sed 's/.*<title>//;s/ (.*//;s/&[^;]*;//g'
    fi
}
#$1=main url
#$2=Countries
#   If language is not chosen one then..get first match from AKA pagif none match use ti (Doesnt work for Two Brothers)
#   OR Get the First Country. If it is not in the target list get first match from AKA page. if none match use title (doesnt work for Leon)
IMDB_EXTRACT_AKA_TITLE() {
    url="$1/releaseinfo#akas"
    url=$( echo "$url" | sed -r 's,//r,/r,g' )
    DEBUG "url=[$url]"
    if wget -O "$gTmpFile.aka" "$url" ; then
        countries=$(CSV_TO_EGREP "$2" )
        awk '

function mycountry(c) {
    return match(c,/^'"$countries"'$/);
}

        BEGIN { country=""; }
/<title>/ {
        title=$0 ; 
        sub(/[^>]+>/,"",title);
        sub(/ +\([0-9]+.*/,"",title);
        gsub(/&[^;]+;/,"",title);
        print "DBG: default", title;
    }
/\/Recent\// {
    if (country == "") {
        country = $0;
        sub(/.*\/Recent\//,"",country);
        sub(/".*/,"",country);
        if (mycountry(country)) {
            print "DBG: RELEASED", title, country;
            print title;
            force_exit=1
            exit 0;
        } else {
            #print "DBG: Country -> " country , title;
        }
    }
}
/name="akas"/,/<\/table>/ {
    if (index($0,"<td>") > 0) {
        #print "DBG: LINE ->" $0;
        gsub(/<td>/,"");
        gsub(/<\/td>/,"");
        gsub(/&#[0-9]+;/,"?");
        if (count % 2 == 0 ) {
            #Title
            title2=$0;
            print "DBG: Title ->" title2;
        } else {
            #Country List
            split($0,countries,"/") ;
            for (c in countries) { 
                gsub(/^ +/,"",countries[c]);
                gsub(/ +$/,"",countries[c]);
                print "DBG: Country->" countries[c];
                if (mycountry(countries[c])) {
                    print "DBG: AKA" title2,countries[c];
                    print title2;
                    force_exit=1
                    exit 0;
                }
            }
        }
        count++;
    }
}
END {
    if (force_exit) exit 0;
    print "DBG: Fallback ",title;
    print title;
}
' "$gTmpFile.aka"
    fi
    rm -f "$gTmpFile.aka"
}

#Input = none
#Output = indb link to stdout
IMDB_EXTRACT_LINK_FROM_NFO() {
    sed -n '/imdb/ s/.*\(http[^ ]*imdb[a-zA-Z0-9/.:?&]*\).*/\1/p' *.nfo
}

#Input = imdb page to stdin
#Output = list of Genres to stdout. eg 'Action','Comedy','Drama'
IMDB_GET_GENRES() {
    awk -F'|' '
    
    #Find any line with href to Genre and a vertical bar.
    /^<a href="\/Sections\/Genre/ {
     
    #Remove the last hyperlink (to more keywords)
    gsub(/a> <a.*/,"a>") ;

    # Now get each field "<a href="/Sections/Genres/Drama/">Drama</a>" and extra the word after Genres.
    for (i=1;i<=NF;i++) {
         gsub(/.*"\/Sections\/Genres\//,"",$i);
         gsub(/\/.*/,"",$i) ;
          print $i
      }
  }'

}
#Input = $1 = filename containing imdb page 
#Output = list of Certificates to stdout eg 'USA:R' , 'UK:PG'
IMDB_GET_CERTIFICATES() {
    if [ -z "$unpak_imdb_certificate_country_filter" ] ; then return 1 ; fi
    for country in $(echo "$unpak_imdb_certificate_country_filter" | sed 's/,/ /g') ; do
        if grep 'List?certificates' "$1" | sed 's/.*certificates=//;s/&&.*//;s/%20/ /g;s/:/-/g;' | grep "$country" ; then
            return 0
        fi
    done
    return 1
}

#######################################################################
# JOB CONTROL
#nzbget queues jobs in order but sometimes its useful to let short jobs
#jump the queue. So we need some kind of job control.
#Its not perfect and two jobs may start at the same time!
#TODO: Not implemented
#######################################################################
job_file="/usr/local/etc/newsbin/tmp/unpak.job"
JOB_WAIT() {

    this_pid="$1"

    this_wait=0
    wait_inc=10
    max_wait=$(( $unpak_maximum_par_repair_minutes*2*60*60 ))
    locked=0
    while [ $locked -eq 0 -a $wait -lt $max_wait ] ; do
        if [ ! -f "$job_file" ] ; then
            if JOB_LOCK ; then return 0 ; fi
        else
            that_pid=$(cat $job_file)
            if [ "$that_pid" -eq "$this_pid" ] ; then return 0 ; fi
            if [ ! -d /proc/$that_pid ] ; then
                #Process gone
                if JOB_LOCK ; then return 0 ; fi
            fi
        fi
        sleep $wait_inc
        this_wait=$(( $this_wait + $wait_inc ))
    done
    return 1
}

JOB_LOCK() {
    this_pid="$1"
    echo "$this_pid" > "$job_file"
    return  [ "$(cat $job_file)" = "$this_pid" ]
}

###################################################################################
# GENRE CONTENT FUNCTIONS
###################################################################################
# Create Genre Folder. This will have sub folders based on Genre
# Action/Drama etc. and Certification UK:PG etc.

###################################################################################
# RECENT CONTENT FUNCTIONS
###################################################################################

# Create two folders $unpak_recent_dir and $unpak_recent_dir2
# These will contain hard links to recently downloaded files. 
# Each time the script runs it will adjust the contents of these folders.
#
# If the user has already deleted some original content, then the 
# corresponding hard links are deleted. (This is done by tracking the number
# of hard links via 'ls -l'
#
# If the user deletes the Recent link then delete the Original Content
# TODO: This should be optional.

# $1 = category if any
CREATE_RECENT_LINKS() {

    if [ "$unpak_recent_age" -eq 0 ] ; then return 0 ; fi

    #We dont want stuff in PIN:FOLDERS appearing in Recent folders.
    if IS_SUBDIR "$PWD" "$unpak_nmt_pin_root" ; then
        return 0;
    fi


    unpak_recent_dir=$( CREATE_FOLDER_RELATIVE_TO_DESTDIR "$unpak_recent_dir" )
    DEBUG "unpak_recent_dir=($unpak_recent_dir)"

    if [ "$unpak_recent_age2" -gt 0 ] ; then
        DEBUG "unpak_recent_dir2=($unpak_recent_dir2)"
        unpak_recent_dir2=$( CREATE_FOLDER_RELATIVE_TO_DESTDIR "$unpak_recent_dir2" )
        DEBUG "unpak_recent_dir2=($unpak_recent_dir2)"
    fi

    #Convert .ext1,.ext2,.ext3 to (\.ext1|\.ext2|\.ext3)$ for egrep
    name_clause="$( CSV_TO_EGREP "$unpak_recent_extensions")$"
    #Create duplicate hard links to all new files
    d="$PWD"
    tag="[$(echo "$1" | sed 's,/,-,g')]"
    date="$(date '+%y.%m.%d')"
    INFO "Creating hard links from [$d] using tag = [$tag]"
    #(cd "$unpak_recent_dir" ; find "$d" -type f | egrep -i "$name_clause" | EXEC_FILE_LIST "touch '\1' ; ln '\1' './$tag-\3'" "" )
    if [ -f "$gTmpFile.moved_files" ] ; then
        (cd "$unpak_recent_dir" ; egrep -i "$name_clause" "$gTmpFile.moved_files"  | EXEC_FILE_LIST "touch '\1' ; ln '\1' './${date}-\3-${tag}\4'" "" )
    fi

    RECENT_MOVE_OR_DELETE "$unpak_recent_age" "$unpak_recent_dir" "$unpak_recent_age2" "$unpak_recent_dir2" 
    RECENT_MOVE_OR_DELETE "$unpak_recent_age2" "$unpak_recent_dir2" "" "" 
}

CSV_TO_EGREP() {
    echo "$1" | sed 's/^/(/;s/,/|/g;s/\./\\./g;s/$/)/'
}

RECENT_MOVE_OR_DELETE() {
    age="$1"
    from="$2"
    age2="$3"
    to="$4"

    DEBUG "RECENT age=$age from [$from]  to=$to arg2=$age2"

    if [ -z "$age" -o "$age" -eq 0 ] ; then return 0 ; fi

    DEBUG "REMOVE HARD LINKS"
    #Remove hard links if original file is gone : ie with only one link ref in ls -l
    (cd "$from" ; LAST_LINK | EXEC_FILE_LIST "rm -f '\1'" "" )

    if [ -n "$age2" -a "$age2" -gt 0 -a -n "$to" ] ; then
        #Move older files
        cmd="mv '\1' '$to/.'"
    else
        #Delete older files
        cmd="rm -f '\1'"
    fi
    DEBUG "RECENT MANAGE HARD_LINKS from [$from] age=$age [$cmd]"
    (cd "$from" ; find . -type f -mtime +$age | EXEC_FILE_LIST "$cmd" "" )
}

############################################################################
# PIN FOLDER HACK 
# If a category begins with 'PIN:FOLDER' then replace that with the path
# to the pin folder. This is simply a folder burried in a heirachy of
# similarly named folders. The path to the folder is defined by
# $unpak_nmt_pin_root and the $unpak_nmt_pin
############################################################################

NMT_MAKE_PIN_FOLDER() {
    INFO "CREATING PIN FOLDER"
    folders="1 2 3 4 5 6 7 8 9"
    start="$PWD"

    #Make the target folder.
    mkdir -p "$nmt_pin_path"

    #We create some dummy folders. Symlinks would have been perfect here
    # as the would create unlimited depth unfortunately
    #they dont show up in the NMT browser. 
    #so we only create a subset of possible combinations. (to conserve disk space)
    cd "$nmt_pin_path"
    last_digit=1
    while [ ! "$PWD" -ef "$unpak_nmt_pin_root" -a "$PWD" != "/" ] ; do
        cd ..
        if [ $(ls | LINE_COUNT) -le 1 ] ; then
            mkdir -p $folders
            if [ $last_digit -eq 0 ]; then
                # Create some more dummy folders in 'cousin' folders of correct letters.
                for i in $folders ; do
                    (cd $i ; mkdir -p $folders ; cd .. ) 
                done
            fi
        fi
        last_digit=0
    done
    chmod -R a+rw "$unpak_nmt_pin_root"
    cd "$start"
    INFO "DONE CREATING PIN FOLDER"
}

#Output = Pin Folder susbstituted
#0=substitued 1=not substitued
NMT_SUBSTITUTE_PIN_FOLDER() {
    d="$1"

    case "$1" in
        $unpak_nmt_pin_flag*)
            #Convert 2468 to /pin/path/2/4/6/8/
            nmt_pin_path="$unpak_nmt_pin_root/"$(echo $unpak_nmt_pin | sed 's/\(.\)/\/\1/g')   
            DEBUG "PIN FOLDER IN [$1] s*^$unpak_nmt_pin_flag*$nmt_pin_path*"

            #Convert $unpak_nmt_pin_flag/a/b/c to /pin/path/2/4/6/8/a/b/c
            new_d=$(echo "$1" | sed "s*^$unpak_nmt_pin_flag*$nmt_pin_path*")
            if [ "$new_d" != "$1" ] ; then
                if [ ! -d "$nmt_pin_path" ] ; then
                    ( NMT_MAKE_PIN_FOLDER )
                fi
                echo "$new_d"
                return 0
            fi
            ;;
        *) 
            ;;
    esac
    echo "$1"
    return 1
}

CREATE_FOLDER_RELATIVE_TO_DESTDIR() {
    ( cd "$nzbget_DestDir" ; mkdir -p "$1" ; cd "$1" ; pwd )
}


#Take a list of files and return those with ">1 links
LAST_LINK() {
    ls -l | awk '$2 == 1 { gsub(/[^:]+:.. /,"") ; print }' 
}

# Pass a list of files to some command '\1' is the file path \2=folder \3=name(without ext) \4=ext
# $2 = any shell options or "--" if none
# Leaving $2 unquoted allows ""
EXEC_FILE_LIST() {
    sep=":"
    sep2=";"
    dir="(|.*\/)"
    nameExt="([^/]+)(\.[^./]*)"
    nameNoExt="([^./]+)()" #Note must anchor with '$' when used otherwise will match extensions.
    case "$1" in *$sep*) sep="$sep2" ;; esac
    cat > $gTmpFile.exec

    sed -rn "s$sep^($dir$nameExt)\$$sep$1${sep}p" $gTmpFile.exec > "$gTmpFile.sh"
    sed -rn "s$sep^($dir$nameNoExt)\$$sep$1${sep}p" $gTmpFile.exec >> "$gTmpFile.sh"

    if [ $unpak_debug_mode -eq 1 ] ; then
        DEBUG "BEGIN FILE LIST for $1 : $2"
        LOGSTREAM INFO "sh-file" < $gTmpFile.exec
        LOGSTREAM INFO "sh-cmd" < $gTmpFile.sh
        rm -f $gTmpFile.exec
    fi

    ( echo 'set -e ' ; cat $gTmpFile.sh ) | sh $2

    rm -f $gTmpFile.sh
}
NO_RARS() { ! ls *.rar > /dev/null 2>&1 ; }
SET_PASS() { gPass=$1 ; INFO "PASS $1" ; }

#Uses PHP
NMT_CRC32() {
    if [ -f "$unpak_php_bin" ] ; then
        INFO "$unpak_php_bin"
        echo '<?php print ("xx".dechex(crc32(file_get_contents("'"$1"'")))) ?>' | "$unpak_php_bin" | sed -n '/^xx/ s/xx//p'
        return 0
    else
        ERROR "$unpak_php_bin not found"
        echo 0
        return 1
    fi
}



##################################################################################
#Some global settings
finished_nzb_ext=".completed"
gTmpFile="/tmp/unpak.$$"
flatten="=@="
##################################################################################
# MAIN SCRIPT
##################################################################################
MAIN() {
    # Make a logfile


    INFO "SCRIPT_FOLDER=[$SCRIPT_FOLDER] PIN $unpak_nmt_pin"

    if [ $unpak_pause_nzbget -eq 1 ] ; then
        PAUSE_NZBGET
    fi


    LOG_ARGS "$@"

    NZB_NICE_NAME=$(GET_NICE_NZBNAME "$arg_nzb_file") 

    CLEAR_FAKEFILES ""
    CLEAR_TMPFILES

    #Only run at the end of nzbjob
    if [ "$arg_nzb_state" -ne 1 ] ; then
        exit
    fi

    INFO
    INFO " ====== Post-process Started : $NZB_NICE_NAME $(date '+%T')======"

    CHECK_SETTINGS || exit 1

    if [ "$arg_par_fail" -ne 0 ] ; then
        ERROR "Previous par-check failed, exiting"
        NMT_FAKEFILE ERR "PAR Previous par-check failed"
        exit 1
    fi

    case "$arg_par_check" in
        0)
            if [ -f _brokenlog.txt -a "$external_par_check" -ne 1 ] ; then
                ERROR "par-check is disabled or no pars present, but a rar is broken, exiting"
                NMT_FAKEFILE ERR "UNRAR is broken"
                exit 1
            fi
            ;;
       1) ERROR "par-check failed, exiting" 
          NMT_FAKEFILE ERR "PAR check failed" 
          exit 1 ;;
       2) true ;; # Checked and repaired.
       3) WARNING "Par can be repaired but repair is disabled, exiting"
          NMT_FAKEFILE WARN "PAR repair disabled"
          exit 1 ;;
    esac

    VERSION_CHECK

    gUnrarState="OK"
       
    if [ "$arg_par_check" -eq 0 -a "$external_par_check" -eq 1 ] ; then
        if ! WAITING_FOR_PARS ; then
            SET_PASS 1
            #First pass. Try to unrar. 
            INFO "$SCRIPT_NAME : PASS 1"
            INIT_ALL_RAR_STATES
            if NO_RARS || ! UNRAR_ALL ; then
                if ! UNPAUSE_PARS_AND_REPROCESS ; then
                    SET_PASS 2
                    # Cannot unpause or reprocess. Try to fix now..
                    PAR_REPAIR_ALL && UNRAR_ALL || true
                fi
            fi
        else
            SET_PASS 2
            INFO "$SCRIPT_NAME : PASS 2"
            #Second pass. Now pars have been fetched try to repair and unrar
            CLEAR_WAITING_FOR_PARS
            PAR_REPAIR_ALL && UNRAR_ALL || true
        fi
    else
        SET_PASS 0
        #script is not processing pars. (no pars or nzbget has repaired already)
        INIT_ALL_RAR_STATES
        UNRAR_ALL || true
    fi
    chmod -R a+rw . || true
    # No logging after this point as folder is moved.
    if [ $unpak_pause_nzbget -eq 1 ] ; then
        UNPAUSE_NZBGET
    fi
    cat=
    if ! WAITING_FOR_PARS ; then
        if [ "$gUnrarState" = "OK" -a -n "$unpak_completed_dir" -a "$nzbget_AppendNzbDir" = "yes" ] ; then
            RELOCATE 
        fi
    fi
    INFO "BEGIN Created Recent Links PWD=[$PWD]"
    CREATE_RECENT_LINKS "$cat"
    LOG INFO END Created Recent Links
    LOG_END "$gUnrarState"
    LOG INFO THE END
}
###################### Parameters #####################################

# Parameters passed to script by nzbget:
#  1 - path to destination dir, where downloaded files are located;
#  2 - name of nzb-file processed;
#  3 - name of par-file processed (if par-checked) or empty string (if not);
#  4 - result of par-check:
#      0 - not checked: par-check disabled or nzb-file does not contain any
#          par-files;
#      1 - checked and failed to repair;
#      2 - checked and sucessfully repaired;
#      3 - checked and can be repaired but repair is disabled;
#  5 - state of nzb-job:
#      0 - there are more collections in this nzb-file queued;
#      1 - this was the last collection in nzb-file;
#  6 - indication of failed par-jobs for current nzb-file:
#      0 - no failed par-jobs;
#      1 - current par-job or any of the previous par-jobs for the
#          same nzb-files failed;
# Check if all is downloaded and repaired


TEST() {
SET_DEFAULT_SETTINGS
for i in \
"http://www.imdb.com/title/tt0060196" \
http://www.imdb.com/title/tt0167260 http://www.imdb.com/title/tt0962726/ \
http://www.imdb.com/title/tt0338512 http://www.imdb.com/title/tt0325710/ \
http://www.imdb.com/title/tt0468569 http://www.imdb.com/title/tt1034331/ \
http://www.imdb.com/title/tt0412142 http://www.imdb.com/title/tt1213574/ \
http://www.imdb.com/title/tt0446059 ; do
    wget -qO x.html "$i"
    IMDB_EXTRACT_TITLE "$i" x.html
done
exit
}

if [ "$#" -lt 6 ]
then
    echo "*** NZBGet post-process script ***"
    echo "This script is supposed to be called from nzbget."
    echo "usage: $0 dir nzbname parname parcheck-result nzb-job-state failed-jobs"
    #exit
fi

arg_download_dir="$1"   
arg_nzb_file="$2" 
arg_par_check="$4" 
arg_nzb_state="$5"  
arg_par_fail="$6" 
arg_category="${7:-}"


SCRIPT_NAME=$(BASENAME "$0" "")

SCRIPT_FOLDER=$( cd $(DIRNAME "$0") ; pwd )

SET_DEFAULT_SETTINGS

MERGE_UNPAK_SETTINGS

cd "$arg_download_dir" 

#AUTO_CATEGORY_FROM_IMDB ; exit # TODO DELETE

#TODO DELETE
#mkdir -p "$arg_download_dir.2"
#ln * "$arg_download_dir.2/."

MAIN "$@" 2>&1 | TEE_LOGFILES unpak.txt unpak.html
if CHECK_UNRAR_STATE ; then
  rm -f unpak.html
fi

#
# vi:shiftwidth=4:tabstop=4:expandtab
#
# Return status to nzbget
#  93 - post-process successful (status = SUCCESS);
#  94 - post-process failed (status = FAILURE);

POSTPROCESS_STATUS=0

    if CHECK_UNRAR_STATE ; then
        POSTPROCESS_STATUS=93
        exit $POSTPROCESS_STATUS
    else
        POSTPROCESS_STATUS=94
        exit $POSTPROCESS_STATUS
    fi

exit $POSTPROCESS_STATUS
