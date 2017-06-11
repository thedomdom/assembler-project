# MCU 8051 IDE: Virtual HW configuration file
# Project: eierkocher

MultiplexedLedDisplay {{0 3 1 3 2 3 3 3 4 3 T0 2 5 3 T1 2 6 3 T2 2 7 3 T3 2} {0 7 1 6 2 5 3 4 4 3 T0 3 5 2 T1 2 6 1 T2 1 7 0 T3 0} 430x225+1474+579 {} red 50 1}
LedPanel {{4 - 0 2 5 - 1 2 6 - 2 2 7 - 3 -} {4 - 0 7 5 - 1 6 6 - 2 5 7 - 3 -} 380x130+1510+412 {0. active| 1. horn | 2. heating} red}
SimpleKeyPad {{4 - 0 0 5 - 1 - 6 - 2 - 7 - 3 -} {4 - 0 6 5 - 1 - 6 - 2 - 7 - 3 -} 265x125+1573+33 Taster {4 0 0 0 5 0 1 0 6 0 2 0 7 0 3 0} 0}
Ds1620 {{4 1 0 1 5 1 1 1 2 1 3 1} {4 3 0 7 5 4 1 6 2 5 3 2} 500x160+1418+210 {} 200 408 0 306x156+1605+841 normal -6 0 1}
