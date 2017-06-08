# MCU 8051 IDE: Virtual HW configuration file
# Project: eierkocher

MultiplexedLedDisplay {{0 1 1 1 2 1 3 1 4 1 T0 3 5 1 T1 3 6 1 T2 - 7 1 T3 -} {0 7 1 6 2 5 3 4 4 3 T0 7 5 2 T1 6 6 1 T2 - 7 0 T3 -} 430x225+1082+30 {} red 50 1}
LedPanel {{4 - 0 0 5 - 1 0 6 - 2 0 7 - 3 -} {4 - 0 4 5 - 1 6 6 - 2 5 7 - 3 -} 380x130+1100+303 {1. is_active| 2. hupe | 3. heizstab} red}
SimpleKeyPad {{4 - 0 0 5 - 1 - 6 - 2 - 7 - 3 -} {4 - 0 7 5 - 1 - 6 - 2 - 7 - 3 -} 265x125+1083+483 Taster {4 0 0 1 5 0 1 0 6 0 2 0 7 0 3 0} 1}
Ds1620 {{4 3 0 0 5 3 1 0 2 0 3 3} {4 4 0 3 5 5 1 2 2 1 3 3} 500x160+1007+634 {} 200 256 1 306x690+1621+30 normal 22 0 1}
