Spacewire testing with the STAR Dundee brick
============================================

HW setup
--------

1. Connect the brick to the Windows laptop, over the USB Type B (printers) to USB Type A cable.
2. Install the STAR Dundee USB Brick SW (`spw_usb_win_x86-64_v2.61.1_2`)
3. Launch it from `C:\Program Files\STAR-Dundee\Validation Software\run.bat`

4. On the GR740 side, connect a SpW cable from this port (marked with `o`)...

```
    x x x
    o x x
    x x x
```

   ...to the STAR Dundee brick `Link 1`.

5. Upon powering up the GR740, you should be seeing the brick's Link 1 LED turn green
6. Now compile this application, and launch the generated binary inside GRMON
7. On the Windows side, go to the "Simple Test" window on the top-right, and enter this payload:

```
    1 9 1 2 3
```

   This payload, routing-wise, means: 

   - exit from Link 1
   - then enter through AMBA port 9
   - with payload 1 2 3

   So when you click on "Send Packet", the application will show - on the GRMON side - this:

```
    SPW0: Recevied 1 packets
     PKT of length 3 bytes, 0x01 0x02 0x03 0x00 0x00 0x00 0x00 0x00...
```

8. Now let's send from the GRMON side. Click on "Receive Packets" and enter this on the 
   GRMON prompt:

```
    starting packet processing loop. enter command:

    x0 1 3 1 2 3 4 5 6 7 8 9
```

   This means: 

   - Use device 0 (grspw0)
   - exit though link 1 (the `o` above)
   - then enter towards target 3 (The PC side of the USB brick)
   - with payload 1 2 3...

   And you should see the packet arrive in the GUI of the Brick.
