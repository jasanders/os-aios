Installation:

1. Copy all files to the /usr/local/etc
2. Add following lines to beginning of the /usr/local/etc/rcS file:

/sbin/insmod /usr/local/etc/venus_ir_new.ko
/usr/local/etc/irfake4&

3. Reboot


//Usage

By default keys that not assigned in the configuration file will be ignored so if you need send it to the player you must
specify -r switch (ideal for key rearrangement) but keys will be redirected only if at least one key for current device code is configured, 
to omit this use -R switch.

Switch –f Path to the alternative configuration file, example irfake4 –f /usr/local/etc/blabla/test.txt
Switch –c Capture mode, just captures pressed keys and show his code
Switch –C Raw capture mode

For advanced users:

    Switch -b Time (debounce) in milliseconds, to prevent repetition of the key press. Any keys pressed with greater interval will be ignored.
    Switch -х Reverse code detection (when first byte is key code).
    Switch -m Driver mode 0 or 1 (SINGLE word, DOUBLE word)
    Switch -p IR Protocol selection:

    NEC = 1
    RC5 = 2
    SHARP = 3
    SONY = 4
    C03 = 5
    RC6 = 6

Captured keys must be in the following format to work properly:

    1. Key length 8 symbols or 4 bytes
    2. First byte XOR second byte must be equal 0xFF


//Configuration format

1) Type 0: Substitution, first value is key code that we press and second code that we send to the player
Example "0","b44bb649","a05f686c"

2) Type 1: System command, first value is key code that we press and second system command
Example "1","f609b649","/bin/sh -c reboot"

3) Type 2: SDK4 IpodCGI (Internal command) first value is key code that we press and second internal command
Example "2","f609b649","left"

4) Type 5: Substitution extended, same as standard type except we need to press two consecutive keys instead of one
Example "5","f00fb649","e41bb649","af50686c"

5) Type 3: System command extended, same as standard type except we need to press two consecutive keys instead of one
Example "3","f00fb649","e51ab649","/bin/sh -c reboot"

6) Type 4: SDK4 IpodCGI (Internal command extended) same as standard type except we need to press two consecutive keys instead of one
Example "4","f00fb649","e51ab649","left"

To wakeup your player properly while using alternative remote control you must specify wakeup key POWERKEY_IRRP
(In this case pressed key will be configured as wakeup key) (Only for Type: 0-2)
Example: "0","b44bb649","a05f686c","POWERKEY_IRRP"

P.S. If you have new Jupiter kernel together with old Mars CPU and want to use POWERKEY_IRRP you must activate this option after IR module loading.
echo "J_MODE|1" > /sys/devices/platform/VenusIR/powerkey_irrp_new

