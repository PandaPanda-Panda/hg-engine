.nds
.thumb

.include "armips/include/battlescriptcmd.s"
.include "armips/include/abilities.s"
.include "armips/include/itemnums.s"
.include "armips/include/monnums.s"
.include "armips/include/movenums.s"

.create "build/move/battle_sub_seq/1_092", 0

a001_092:
    ifmonstat IF_MASK, BATTLER_DEFENDER, MON_DATA_MOVE_STATE, 0x200400C0, _0060
    ifmonstat IF_MASK, BATTLER_DEFENDER, MON_DATA_STATUS_2, 0x200000, _0060
    gotosubscript 76
    transform
    printmessage 0x159, 0xE, 0x1, 0x2, "NaN", "NaN", "NaN", "NaN"
    waitmessage
    wait 0x1E
    endscript
_0060:
    changevar VAR_OP_SETMASK, VAR_10, 0x40
    endscript

.close
