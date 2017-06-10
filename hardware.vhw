# MCU 8051 IDE: Virtual HW configuration file
# Project: eierkocher

MultiplexedLedDisplay {{0 1 1 1 2 1 3 1 4 1 T0 3 5 1 T1 3 6 1 T2 - 7 1 T3 -} {0 7 1 6 2 5 3 4 4 3 T0 7 5 2 T1 6 6 1 T2 - 7 0 T3 -} 430x225+1473+582 {} red 50 1}
LedPanel {{4 - 0 2 5 - 1 2 6 - 2 2 7 - 3 -} {4 - 0 7 5 - 1 6 6 - 2 5 7 - 3 -} 380x130+1520+417 {0. active| 1. horn | 2. heating} red}
SimpleKeyPad {{4 - 0 0 5 - 1 - 6 - 2 - 7 - 3 -} {4 - 0 6 5 - 1 - 6 - 2 - 7 - 3 -} 265x125+1550+43 Taster {4 0 0 0 5 0 1 0 6 0 2 0 7 0 3 0} 0}
Ds1620 {{4 1 0 1 5 1 1 1 2 1 3 1} {4 3 0 7 5 4 1 6 2 5 3 2} 500x160+1410+213 {} 200 408 0 306x156+1605+841 normal 28 0 1}
