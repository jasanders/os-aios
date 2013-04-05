ABOUT DMD RMUSIC JUKEBOX:
This is RSS based application, is created for playing your local music files on the Realtek based players (RTD 1073, 1283 and 1185). This application is free, it was created by Czech DMD team (Me & Derby00 from http://www.hddplayer.cz), is based on GeekyHMB Random RSS Music Version 1.0 for HMB, Hyundai & Ellion box by Zozodesbois from http://geekyhmb.fr.cr/content/Random_RSS_Music , many thanks for the first step and great idea.
If you like our work and if you want to try this application, or add it to your own custom firmware, please contact me via email and send me web address of your custom firmware project, I will then send you link and password to get the current version of our RM Jukebox. Please respect the rights of authors and publish our names (DMD and GeekyHMB) in their announcements.
If you modify or optimize our scripts so that they are working on your players, please send me a copy.
I welcome your ideas for further development of this application. 

HOW IT WORKS:
So, would be best if you look at my videos on YouTube channel:
v. 2.2
http://www.youtube.com/watch?v=s9NhGrOoII0
v. 2.0
http://www.youtube.com/watch?v=bc1v2J37x2A

HOW TO INSTALL DMD RMJ:
1. Download and unzip archive, copy contents of /tmp_orig/www/cgi-bin/ to youre web server directory on the player and change attributeson this cgi scripts with chmod 777 over telnet
2. Copy folder /usr/local/bin/scripts/DMD_RMJ to youre player, if you need change ddirectory to other (if youre FW use squashfs for example), then you need edit path to scripts in all 4 RSS scripts. New path must be set in variable scriptPath on the begining of all scripts in onEnter section.
3. You need add 2 links somewhwre in youre IMS menu rss script, or add shortcut for buttons to onUserInput section, see examples at the end of this document.

HOW CONTROL THIS JUKEBOX:
- In Folders Explorer (Folder Select):
(same in album and random mode)
Cursor arrow keys UP / DOWN and OK - scroll in the list of folders
PLAY - starts playing the selected folder in the album mode
REPEAT - sets the selected folder as the default for RM Jukebox and generates a current playlist

- In Random play mode:
PLAY - Start / pause playback
REPEAT or SEARCH - to switch between album mode (for currently played track) and Random play
SLOW - runs Folders Explorer
PREV. / NEXT - Repeat the last / next track
OK - start playback if is stopped

- In Album mode:
PLAY - Start / pause playback
REPEAT - toggles between playback modes for order / random within a given album (folder)
SEARCH - runs CoverFlow to select the album by cover
SLOW - runs Folders Explorer
PREV. / NEXT - previous / next track
UP / DOWN - set the ordinal number of the track
1, 2 .. 0 - sets the ordinal number of the track
OK - confirm and start playing track by ordinal number
LEFT / RIGHT - scroll a text list of tracks (at IAMM only after stopping playback)

CoverFlow:
LEFT / RIGHT - scroll the list of albums (folders)
UP / DOWN - page scroll through the list of albums (folders)
1, 2 .. 0 - set album by the ordinal number
OK - confirm and start playback of the selected album
PREV. / NEXT - scrolling a text list of albums (folders)
               
KNOWING ISSUES:
- I can not guarantee 100% functionality of this scripts on all Realtek based players, because each brand implements support for RSS in firmware differently.
- Some music files not played, is mostly due to the existence of 2 spaces consecutively in filename, or foldername.  

Sorry for my bad English!

Martini(CZ) , email: w0m@seznam.cz



EXAMPLES:
Example for add item links to youre menu.rss:

<item>
    <title>DMD RMusic Jukebox (Album)</title>
    <link>/usr/local/bin/scripts/DMD_RMJ/RMalbum.rss</link>
    <image>/usr/local/bin/scripts/DMD_RMJ/rmjukebox.jpg</image>
</item>
<item>
    <title>DMD RMusic Jukebox (Random)</title>
    <link>/usr/local/bin/scripts/DMD_RMJ/RMusic.rss</link>
    <image>/usr/local/bin/scripts/DMD_RMJ/rmjukebox.jpg</image>
</item>

 
Example for add shortcut to run DMD RMusic Jukebox in Album Mode with PLAY and 
in Random Mode with REPEAT button on youre RC:

  <onUserInput>
    <script>
    .
    .
    .
    else if(userInput == "video_play" || userInput == "video_pause")
		{
			jumpToLink("rmAlbum");
			ret = "true";
		}
    else if(userInput == "video_search")
		{
			jumpToLink("mcBrowser");
			ret = "true";
		}
    else if(userInput == "video_repeat" || userInput == "video_abrepeat")
		{
			jumpToLink("rmJukebox");
			ret = "true";
		}

      ret;
    </script>
  </onUserInput>

<rmJukebox>
<link>/usr/local/bin/scripts/DMD_RMJ/RMusic.rss</link>
</rmJukebox>

<rmAlbum>
<link>/usr/local/bin/scripts/DMD_RMJ/RMalbum.rss</link>
</rmAlbum>
