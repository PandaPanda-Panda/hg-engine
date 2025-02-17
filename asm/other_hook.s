.text
.align 2
.thumb

.include "offset_def.s"

/*不同形态的图片读取*/
.global PokePicLoad
PokePicLoad:
ldr r6, [sp, #0x18]
ldr r1, [sp, #0x1C]
mov r0, #0x0
strh r0, [r5, #0x6]
strb r0, [r5, #0x8]
str r0, [r5, #0xC]
push {r0-r3}
sub sp, #0x4
str r1, [sp, #0x0]
mov r0, r5
mov r1, r4
mov r2, r3
mov r3, r6
bl GetOtherFormPic
add sp, #0x4
cmp r0, #0x0
bne HaveNewPic
pop {r0-r3}
ldr r0, =0x020701F8 + 1
bx r0

HaveNewPic:
pop {r0-r3}
pop {r3-r7,pc}

//小图标色板
.global IconPalGet
IconPalGet:
push {r3}
bl PokeIconPalNumGet
pop {r3}
ldr r1, =0x020743F8 + 1
bx r1





// 02247910
// edits to the beginning of EncountParamSetRare to extract species + form
// r0 is species | (form << 11)
// treating r4-r7 as free since this function is only called at the end of other ones
.global get_form_out_of_encounter_species_rare
get_form_out_of_encounter_species_rare:
// ldr r4, =0xF800
mov r4, #0xF8
lsl r4, #8
and r4, r0
lsr r4, #11
ldr r5, =space_for_setmondata
strb r4, [r5]

// ldr r4, =0x07FF
mov r4, #7
lsl r4, #8
add r4, #0xFF
and r0, r4 // make r0 solely the species


// reset the function up:
push {r3-r7, lr}
sub sp, #0x28
str r0, [sp, #0x10]
ldr r6, [sp, #0x40]
ldr r4, =0x02247918 | 1
bx r4



// 02247A00 - end of above function
// sp1C is param
// need to set form
.global modify_species_encounter_data_rare
modify_species_encounter_data_rare:
push {r0-r3}

ldr r0, [sp, #(0x1c+0x10)] // pp
mov r1, #112 // ID_PARA_form_no
ldr r2, =space_for_setmondata // &form
bl call_setmondata

ldr r0, [sp, #(0x1c+0x10)] // pp
bl UpdatePassiveForms

// hopefully with form set, this grabs everything correctly (it should please please please)
ldr r0, [sp, #(0x1c+0x10)] // pp
ldr r3, =0x0206E250 | 1 //RecalcPartyPokemonStats(pp);
bl call_via_r3
ldr r0, [sp, #(0x1c+0x10)] // pp
ldr r3, =0x020722D4 | 1 //ResetPartyPokemonAbility(pp);
bl call_via_r3
ldr r0, [sp, #(0x1c+0x10)] // pp
ldr r3, =0x020712D8 | 1 //InitBoxMonMoveset(ppp);
bl call_via_r3

pop {r0-r3}
add r1, r6, #0
bl 0x0224855C // should not need longcall
ldr r0, [sp, #0x1c]
ldr r5, =0x02247A10 | 1
bx r5

.pool

//02234868
//08018A48
.global hook_7_spriteOffsetSpecies
hook_7_spriteOffsetSpecies:
// sp+18 is form--apparently not.
push {r0-r5, r7}
mov r0, r6
ldr r1, =word_to_store_form_at
ldr r1, [r1]
bl GetSpeciesBasedOnForm // (species, form)
mov r6, r0
pop {r0-r5, r7}

str r0, [sp]
lsl r0, r6, #0x10
lsl r1, r1, #0x18
lsr r0, #0x10

ldr r3, =0x02234870 | 1
bx r3


//02259A14
//08022154
.global hook_12_spriteOffsetSpecies
hook_12_spriteOffsetSpecies:
// pretty sure this one is right.
push {r0-r7}
ldr r1, =word_to_store_form_at
ldr r1, [r1]
ldrh r0, [r5, #2]
bl GetSpeciesBasedOnForm // (species, form)
strh r0, [r5, #2]
pop {r0-r7}

ldr r0, [r5, #4]
str r0, [sp]
ldrb r3, [r5, #1]
ldrh r0, [r5, #2]

ldr r2, =0x02259A1C | 1
bx r2


//02259DBC
.global hook_12_spriteOffsetSpecies_escapeFromBall
hook_12_spriteOffsetSpecies_escapeFromBall:
push {r0-r7}
ldr r1, =word_to_store_form_at
ldr r1, [r1]
ldrh r0, [r4, #2]
bl GetSpeciesBasedOnForm // (species, form)
strh r0, [r4, #2]
pop {r0-r7}

mov r2, r5
str r0, [sp]
ldrb r3, [r4, #1]
add r2, #0x84

ldr r0, =0x02259DC4 | 1
bx r0


//02259C0C
// need to store species to r5+2
.global fix_double_spriteOffsetSpecies
fix_double_spriteOffsetSpecies:
push {r0-r7}
ldr r1, =word_to_store_form_at
ldr r1, [r1]
ldrh r0, [r5, #2]
bl GetSpeciesBasedOnForm // (species, form)
strh r0, [r5, #2]
pop {r0-r7}

ldr r0, [r5, #4]
mov r2, r4
str r0, [sp]
ldrb r3, [r5, #1]

ldr r0, =0x02259C14 | 1
bx r0


.pool

.align 2
.global word_to_store_form_at
word_to_store_form_at:
.word 0



// 02247A18
// edits to the beginning of EncountParamSet to extract species + form
// r0 is species | (form << 11)
// treating r4-r7 as free since this function is only called at the end of other ones
.global get_form_out_of_encounter_species
get_form_out_of_encounter_species:
// ldr r4, =0xF800
mov r4, #0xF8
lsl r4, #8
and r4, r0
lsr r4, #11
ldr r5, =space_for_setmondata
str r4, [r5]

// ldr r4, =0x07FF
mov r4, #7
lsl r4, #8
add r4, #0xFF
and r0, r4 // make r0 solely the species

// reset the function up
//push {r3-r7, lr}
//sub sp, #0x20

str r0, [sp, #0xC]
ldr r0, [sp, #0x3C]
str r1, [sp, #0x10]
str r0, [sp, #0x3C]

ldr r4, =0x02247A24 | 1
bx r4


// 02247B42 - end of above function
// r4 is param
// need to set form
.global modify_species_encounter_data
modify_species_encounter_data:
bl call_setmondata // set the id number
mov r0, r4 // pp
mov r1, #112 // ID_PARA_form_no
ldr r2, =space_for_setmondata // &form
bl call_setmondata

mov r0, r4
bl UpdatePassiveForms

// hopefully with form set, this grabs everything correctly
mov r0, r4
ldr r3, =0x0206E250 | 1 //RecalcPartyPokemonStats(pp);
bl call_via_r3
mov r0, r4
ldr r3, =0x020722D4 | 1 //ResetPartyPokemonAbility(pp);
bl call_via_r3
mov r0, r4 // me when the boxmon is at offset 0 of the PartyPokemon structure so i should be able to just pass it like this and have it work :)
ldr r3, =0x020712D8 | 1 //InitBoxMonMoveset(ppp);
bl call_via_r3

ldr r0, [sp, #0x14]
ldr r3, [sp, #0x40]
mov r1, r7
ldr r5, =0x02247B4C | 1
bx r5

call_setmondata:
ldr r3, =0x0206EC40 | 1
call_via_r3:
bx r3

.pool

.global space_for_setmondata
space_for_setmondata:
.word 0


.global UseItemFormeChange_hook
UseItemFormeChange_hook:
push {r1-r7}

mov r0, r5
mov r1, r4 // so that the memory can be freed
bl UseItemFormeChangeCheck

pop {r1-r7}
cmp r0, #1
bne return_to_0207C2D2
mov r0, #31
ldr r1, =0x0207C2D0 | 1 // else return 31
bx r1

return_to_0207C2D2:
ldr r0, =0x0207C2D2 | 1
bx r0

.pool


.global Sav2_Misc_init_new_fields_hook
Sav2_Misc_init_new_fields_hook:
mov r0, r4
bl Sav2_Misc_init_new_fields // new init function
mov r0, r4
bl 0x0202ADEC // ApricornTrees_Init, should not need longcall honestly
mov r0, #2
ldr r1, =(0x0202A8D4 | 1)
bx r1

.pool


// need to grab species, pid, form
.global grab_sex_for_GetBoxMonData
grab_sex_for_GetBoxMonData:
ldr r1, [sp]
ldrh r0, [r5]
ldr r1, [r1]
ldrb r2, [r6, #0x18]
bl GrabSexFromSpeciesAndForm
ldr r1, =0x0206EA24|1
bx r1

.pool


.global StoreFieldSysPtr
StoreFieldSysPtr:
ldr r1, =gFieldSysPtr
str r4, [r1]

mov r1, #0
str r1, [r0]
ldr r0, [r4]
mov r6, #0x7C

ldr r2, =0x0203E030 | 1
bx r2

.pool

.global gFieldSysPtr
gFieldSysPtr:
.word 0

.global WindowClose
WindowClose:
ldr r0, =0x04000050
mov r1, #0x0
strh r1, [r0]
mov r0, r5
add r0, #0xD2
ldrb r1, [r0, #0x0]
mov r0, #0x40
ldr r2, =0x02041198 + 1
bx r2

.pool


.global gTriggerDouble
gTriggerDouble:
.word 0


.global TryTriggerWildDoubleBattle
TryTriggerWildDoubleBattle:
ldr r2, =0x020272B0 | 1 //SaveBlock2_get
bl bx_r2
ldr r2, =0x02074904 | 1 //SavArray_PlayerParty_get
bl bx_r2
ldr r2, =0x0205442C | 1 //HasEnoughAlivePokemonForDoubleBattle(SavArray_PlayerParty_get(SaveBlock2_get()))
bl bx_r2
cmp r0, #0
beq singleBattle

ldr r2, =0x0201FD44 | 1
bl bx_r2

mov r1, #100
bl __aeabi_uidiv // returns div in r0
cmp r1, #10
blt doubleWildBattle

singleBattle:
mov r1, #0
b skipDoubleWildBattle

doubleWildBattle:
mov r1, #2

skipDoubleWildBattle:
ldr r0, =gTriggerDouble
str r1, [r0]
mov r0, #11
ldr r2, =0x020518D8 | 1
bl bx_r2
ldr r2, =0x0224828C | 1
// fallthrough to bx r2

bx_r2:
bx r2

.pool


// r0 is fight_type, need to check gTriggerDouble above and see if the player palette should be overwritten as the multi battle param would stipulate
.global KeepPlayerPaletteIntact
KeepPlayerPaletteIntact:
ldr r1, =gTriggerDouble
ldr r1, [r1]
cmp r1, #0
bne return_to_022607C4

return_to_022607DA:
cmp r0, #0x4A
beq return_to_022607C4
ldr r2, =0x022607DA|1
bx r2

return_to_022607C4:
mov r0, r7
mov r1, #2
ldr r2, =0x022607C4|1
bx r2

.pool
