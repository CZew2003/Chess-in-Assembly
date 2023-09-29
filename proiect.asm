.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
extern fopen: proc
extern fscanf: proc
extern fprintf: proc
extern fclose: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Chess game",0
area_width EQU 400
area_height EQU 400
area DD 0
format db "%d",10,0
format1 db 10,0
format2 db "%d %d", 10,0

end_game dd 0

cube_height EQU area_height / 8
cube_width EQU area_height / 8
cube_even_color EQU 0fccd9dh
cube_odd_color EQU 0d38f4bh
piece_selected_color EQU 3BCFFCh
king_in_check EQU 0bc2300h
available_cube_color EQU 097F2FFh
stalemate_color EQU 0FF7F50h
symbol_height EQU 48
symbol_width EQU 48
culoare_dorita dd 0
culoare_not_background dd 0
table_pieces dd 6, 6, 6, 6, 6, 6, 6, 6
			 dd 6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 
table_pieces_initially dd 2, 3, 4, 1, 0, 4, 3, 2
			 dd 5, 5, 5, 5, 5, 5, 5, 5
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	6, 6, 6, 6, 6, 6, 6, 6
			 dd	12, 12, 12, 12, 12, 12, 12, 12
			 dd	9, 10, 11, 8, 7, 11, 10, 9


available_cube_x dd 50 dup (-1)
available_cube_y dd 50 dup (-1)
			 
white_to_move dd 1
piece_selected dd 6
piece_selected_x dd -1
piece_selected_y dd -1
cube_selected_x dd -1
cube_selected_y dd -1
check_mate_x dd -1
check_mate_y dd -1
can_move dd 0


stalemate_x1 dd -1
stalemate_x2 dd -1
stalemate_y1 dd -1
stalemate_y2 dd -1


can_en_passant dd 0
en_passant_done dd 0
en_passant_x dd -1
en_passant_y dd -1

can_small_castle_white dd 1
can_big_castle_white dd 1
can_small_castle_black dd 1
can_big_castle_black dd 1


file_init db "save.txt", 0
file_init_mode db "r", 0
file_init_mode1 db "w", 0
variable dd 0
file_init_msj db "%d", 0
file_init_msj1 db "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d", 0
file_init_pointer dd 0
file_init_msj2 db "%d ", 0
file_init_msj3 db "%d", 10, "%d %d %d", 10, "%d %d %d %d", 10, "%d %d %d", 10, "%d %d %d %d", 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24
arg6 EQU 28

include digits.inc
include letters.inc
include black_pieces.inc
include pixil-frame-0.inc

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROURILE PENTRU TOATE FUNCTIILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; macro pentru a fi mai usor de utilizat draw_piece
draw_piece_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call draw_piece
	add esp, 16
endm

draw_pieces_macro macro	
	call draw_pieces
endm

draw_grid_macro macro	
	call draw_grid
endm

click_handle_macro macro x, y
	push x
	push y
	call click_handle
endm

verif_move_is_castle_macro macro old_x, old_y, new_x, new_y, piece 
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_is_castle
endm

verif_move_is_en_passant_macro macro old_x, old_y, new_x, new_y, piece 
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_is_en_passant
endm	
	
check_castle_rights_macro macro old_x, old_y, new_x, new_y
	push old_x
	push old_y
	push new_x
	push new_y
	call check_castle_rights
endm
	
check_double_move_pawn_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call check_double_move_pawn
endm

get_all_possible_moves_macro macro x, y, piece
	push x
	push y
	push piece
	call get_all_possible_moves
endm

verif_king_check_macro macro piece
	push piece
	call verif_king_check
endm

verif_no_moves_macro macro piece
	push piece
	call verif_no_moves
endm
	
make_move_macro macro old_x, old_y, new_x, new_y, old_piece, new_piece
	push old_x
	push old_y
	push new_x
	push new_y
	push old_piece
	push new_piece
	call make_move 
endm
	
verif_promovation_macro macro pos_x, pos_y, piece
	push pos_x
	push pos_y
	push piece
	call verif_promovation
endm
	
reset_the_game_macro macro		
	call reset_the_game
endm

set_element_to_grid_macro macro x, y, piece
	push x
	push y
	push piece
	call set_element_to_grid
endm
	
get_element_from_grid_macro macro x, y
	push x
	push y
	call get_element_from_grid
endm
	
get_cube_macro macro x, y
	push x
	push y
	call get_cube
endm
	
verificare_este_patrat_available_macro macro x, y
	push x
	push y
	call verificare_este_patrat_available
endm
	
is_pin_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call is_pin
endm
	
verif_move_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move 
endm
	
verif_move_pawn_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_pawn 
endm
	
verif_move_knight_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_knight 
endm	
	
verif_move_rook_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_rook 
endm	
	
verif_move_bishop_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_bishop 
endm

verif_move_queen_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_queen
endm		
	
verif_move_king_macro macro old_x, old_y, new_x, new_y, piece
	push old_x
	push old_y
	push new_x
	push new_y
	push piece
	call verif_move_king 
endm		
	
find_the_king_macro macro piece
	push piece
	call find_the_king
endm
	
get_the_color_macro macro piece
	push piece
	call get_the_color
endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

draw_piece proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 6 ; daca este 6 atunci nu se afla nimic pe table
	je final_draw_piece
	jg make_white

make_black:
	lea esi, pieces
	mov culoare_dorita, 0 ; o sa afisam culoarea neagra pentru piesa
	jmp draw_the_piece
make_white:	
	lea esi, pieces
	sub eax, 7 ; daca este alba atunci trebuie sa scadem 7 pentru a determina ce piesa sa desenam
	mov culoare_dorita, -1
	
draw_the_piece:
; in eax avem a cata piesa este
	mov ebx, symbol_width 
	mul ebx
	mov ebx, symbol_height
	mul ebx
	shl eax, 2
	add esi, eax ; gasim locatia de unde incepem sa desenam
	mov ecx, symbol_height ; loopuk pentru desen
	
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli	
	mov eax, [ebp+arg3] ; pointer la coord x
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width ; inmultim cu cate linii trecem peste
	mul ebx
	add eax, [ebp+arg4] ; pointer la coord y
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	mov ebx, culoare_not_background ; daca nu este 0 atunci nu il vom adauga deoarece face parte din afara piesei
	cmp dword ptr [esi], ebx
	jne next_pixel
	mov ebx, culoare_dorita
	mov dword ptr [edi], ebx ; punem in matrice valoarea din culoare_dorita
next_pixel:
	add esi, 4 ; trecem la urmatorul dword
	add edi, 4 ; trecem la urmatorul dword
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	
final_draw_piece:
	popa
	mov esp, ebp
	pop ebp
	ret
draw_piece endp 



; functia draw_pieces - deseneaza piesele pe tabla de sah
draw_pieces proc

	push ebp
	mov ebp, esp
	pusha

	mov ecx, 8

	lea ebx, table_pieces
	; loop prin liniile tablei de sah
draw_pieces_for_loop_linii:
	mov esi, 8
	sub esi, ecx ; memoram ce linie este in esi
	push ecx
	mov ecx, 8
	; loop prin coloanele de sah
draw_pieces_for_loop_coloane:
	mov edi, 8
	sub edi, ecx ; memoram ce coloana e in edi
	
	push esi
	
	mov eax, esi
	mov edx, cube_height
	mul edx
	inc eax
	mov esi, eax ; punem in esi esi * cube_height
	
	mov eax, edi
	mov edx, cube_width
	mul edx
	inc eax
	mov edi, eax ; punem in esi esi * cube_width
	
	
	draw_piece_macro dword ptr [ebx], area, esi, edi ; scriem piesa

	
	pop esi
	add ebx, 4

	loop draw_pieces_for_loop_coloane
	pop ecx
	loop draw_pieces_for_loop_linii
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw_pieces endp






; functia draw_grid - genereaza gridul jocului de sah
draw_grid proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ebx, area

	
	mov ecx, area_height ; facem loop prin inaltimea layout-ului
for_loop_linii:
	mov esi, area_height
	sub esi, ecx ; memoram pe ce linie suntem in esi
	
	push ecx
	mov ecx, area_width ; facem loop prin latimea layout-ului
	
for_loop_coloane:
	mov edi, area_width
	sub edi, ecx ; memoram pe ce coloana suntem in edi
	
	push ecx ; sa nu pierdem valoarea din ecx
	
	get_cube_macro esi, edi ; vedem in ce cub ne aflam 
	
	push eax

	verificare_este_patrat_available_macro ecx, edx ; verificam daca putem pune piesa selectata pe patrat
	
	cmp eax, 1
	pop eax
	je patrat_available
	
verificare_patrat_selectat:
	cmp ecx, piece_selected_x ; verificam daca am selectat o piesa, si o coloram diferit
	jne verificare_sah_mat ; daca nu verificam daca e sah mat 
	cmp edx, piece_selected_y ; verificam daca am selectat o piesa, si o coloram diferit
	jne verificare_sah_mat; daca nu verificam ce culoare ii dam
	jmp patrat_selectat

	
verificare_sah_mat:
	cmp ecx, check_mate_x ; verificam daca e sah mat, si o coloram diferit
	jne verificare_stalemate1 ; daca nu verificam pat
	cmp edx, check_mate_y ; verificam daca e sah mat, si o coloram diferit
	jne verificare_stalemate1 ; daca nu verificam pat
	jmp patrat_in_sah
	
verificare_stalemate1:
	cmp ecx, stalemate_x1
	jne verificare_stalemate2
	cmp edx, stalemate_y1
	jne verificare_stalemate2
	jmp patrat_stalemate
	
verificare_stalemate2:
	cmp ecx, stalemate_x2
	jne verificare_culoare_patrat
	cmp edx, stalemate_y2
	jne verificare_culoare_patrat
	jmp patrat_stalemate
	
	
verificare_culoare_patrat:	
	test eax, 1 ; daca e patrat par afisam culoarea pt patrat par altfel pentru impar
	jz patrat_par
patrat_impar:
	mov dword ptr [ebx], cube_odd_color
	jmp finalizare_coloarare_patrat
	
patrat_par:
	mov dword ptr [ebx], cube_even_color
	jmp finalizare_coloarare_patrat
	
patrat_selectat:
	mov dword ptr [ebx], piece_selected_color
	jmp finalizare_coloarare_patrat
	
patrat_in_sah:
	mov dword ptr [ebx], king_in_check
	jmp finalizare_coloarare_patrat
	
patrat_stalemate:
	mov dword ptr [ebx], stalemate_color
	jmp finalizare_coloarare_patrat
	
patrat_available:
	mov dword ptr [ebx], available_cube_color
	jmp finalizare_coloarare_patrat
	
finalizare_coloarare_patrat:
	pop ecx ; dam pop la ce coloana ne aflam
	add ebx, 4
	
	dec ecx
	cmp ecx, 0
	jg for_loop_coloane
	
	pop ecx ; dam pop la ce linie ne aflam
	dec ecx
	cmp ecx, 0
	jg for_loop_linii
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw_grid endp

	


; functie care se ocupa de evenimentul click
; arg1 y
; arg2 x
click_handle proc
	push ebp
	mov ebp, esp

	pusha
	
	get_cube_macro dword ptr [ebp + arg2], dword ptr [ebp + arg1] ; aflam in ce cub am apasat si le memoram coordonatele in cube_selected
	
	mov cube_selected_x, ecx
	mov cube_selected_y, edx

	get_element_from_grid_macro ecx, edx ; verificam pe ce piesa am apasat
	
	cmp eax, 6 ; daca e spatiu verificam daca putem face o miscare
	je move_piece 
	
	jg white_piece_selected ; daca e peste 6 atunci e piesa alba
	
black_piece_selected:
	cmp white_to_move, 0 ; daca este negru la mutare atunci la urmatoarea miscare avem o piesa selectata
	je set_can_move
	cmp can_move, 1 ; daca este randul lui alb si poate muta can_move = 1 atunci verificam corectitudinea miscarii
	je move_piece
	mov can_move, 0 ; daca nu can_move devine 0
	jmp final_click_handle ; trecem la final
	
white_piece_selected: ; la fel si in cazul piesei albe
	cmp white_to_move, 1
	je set_can_move
	cmp can_move, 1
	je move_piece
	mov can_move, 0
	jmp final_click_handle
	
set_can_move: ; setam can_move cu 1 si salvam pozitia piesei in piece_selected si coordonatele ei
	mov can_move, 1
	mov piece_selected, eax
	mov eax, cube_selected_x
	mov piece_selected_x, eax
	mov eax, cube_selected_y
	mov piece_selected_y, eax
	
	get_all_possible_moves_macro piece_selected_x, piece_selected_y, piece_selected
	; salvam toate miscarile posibile pentru piesa noastra
	
	jmp final_click_handle
	
	
move_piece: ; facem mutarea

	cmp piece_selected, 6 ; daca nu avem o piesa atunci trecem la final
	je final_click_handle
	cmp can_move, 0 ; daca nu poate muta trecem la final
	je final_click_handle
	
	
	verificare_este_patrat_available_macro cube_selected_x, cube_selected_y ; verificam corectitudinea miscarii
	
	cmp eax, 0 ; daca nu e corecta atunci trecem la final
	je final_click_handle

	verif_promovation_macro cube_selected_x, cube_selected_y, piece_selected
	
	cmp eax, 0
	je no_pawn_promovation
	cmp piece_selected, 7
	jl pawn_promovation_black
	
pawn_promovation_white:
	mov piece_selected, 8
	jmp no_pawn_promovation
	
pawn_promovation_black:
	mov piece_selected, 1
	jmp no_pawn_promovation
	
no_pawn_promovation:


	verif_move_is_en_passant_macro piece_selected_x, piece_selected_y, cube_selected_x, cube_selected_y, piece_selected
	; daca este en_passant atunci stergem pionul capturat
	

	verif_move_is_castle_macro piece_selected_x, piece_selected_y, cube_selected_x, cube_selected_y, piece_selected
	; daca este rocada atunci mutam tura corespunzator
	

	make_move_macro piece_selected_x, piece_selected_y, cube_selected_x, cube_selected_y, piece_selected, 6

	

	check_double_move_pawn_macro piece_selected_x, piece_selected_y, cube_selected_x, cube_selected_y, piece_selected
	
	cmp white_to_move, 0
	je verificare_sah_mat_negru
	
verificare_sah_mat_alb:
	verif_no_moves_macro 0
	cmp eax, 1
	jne verificare_conditii_castle
	
	verif_king_check_macro 0
	cmp eax, 1
	jne stalemate
	
sah_mat_alb:
	find_the_king_macro 0
	mov check_mate_x, ecx
	mov check_mate_y, edx
	mov end_game, 1
	jmp verificare_conditii_castle
	
	
verificare_sah_mat_negru:
	verif_no_moves_macro 7
	cmp eax, 1
	jne verificare_conditii_castle

	verif_king_check_macro 7
	cmp eax, 1
	jne stalemate
	
sah_mat_negru:
	find_the_king_macro 7
	mov check_mate_x, ecx
	mov check_mate_y, edx
	mov end_game, 1
	jmp verificare_conditii_castle


stalemate:
	find_the_king_macro 0
	mov stalemate_x1, ecx
	mov stalemate_y1, edx
	
	find_the_king_macro 7
	mov stalemate_x2, ecx
	mov stalemate_y2, edx
	mov end_game, 1
	
	
verificare_conditii_castle:
	check_castle_rights_macro piece_selected_x, piece_selected_y, cube_selected_x, cube_selected_y

	
move_piece_final:
	mov eax, 1
	sub eax, white_to_move
	mov white_to_move, eax ; schimbam cine muta
	mov can_move, 0 ; dam reset la can_move si piece_selected
	mov piece_selected_x, -1
	mov piece_selected_y, -1
	mov available_cube_x[0], -1
	mov available_cube_y[0], -1
	call set_table_to_file
	

final_click_handle:	
	popa
	mov esp, ebp
	pop ebp
	ret 8
	
click_handle endp
	
	
	
	
; functie care determina daca o miscare a fost castle, si daca a fost atunci mutam si tura
; arg1 piesa
; arg2 noua pozitie y
; arg3 noua pozitie x
; arg4 vechea pozitie y
; arg5 vechea pozitie x	

verif_move_is_castle proc
	push ebp
	mov ebp, esp
	
	
	cmp dword ptr[ebp + arg1], 0
	je verif_move_is_castle_king
	cmp dword ptr[ebp + arg1], 7
	jne verif_move_is_castle_final
	; daca piesa nu este rege atunci nu este
verif_move_is_castle_king:

	mov eax, [ebp + arg2]
	sub eax, [ebp + arg4]
	cmp eax, 2 ; verificam daca diferenta la coloane este 2 si e small castle
	je verif_move_is_castle_king_small_castle
	cmp eax, -2 ; verificam daca diferenta la coloane este -2 si e big castle
	je verif_move_is_castle_king_big_castle
	jmp verif_move_is_castle_final
	
verif_move_is_castle_king_small_castle:
	set_element_to_grid_macro dword ptr [ebp + arg3], 7, 6
	
	mov eax, [ebp + arg1]
	add eax, 2
	
	set_element_to_grid_macro dword ptr [ebp + arg3], 5, eax
	jmp verif_move_is_castle_final
	
verif_move_is_castle_king_big_castle:

	set_element_to_grid_macro dword ptr [ebp + arg3], 0, 6
	
	mov eax, [ebp + arg1]
	add eax, 2
	
	set_element_to_grid_macro dword ptr [ebp + arg3], 3, eax
	
	jmp verif_move_is_castle_final
	
	
verif_move_is_castle_final:
	mov esp, ebp
	pop ebp
	ret 20
verif_move_is_castle endp
	

	
; functie care determina daca o miscare a fost en passant
; arg1 piesa
; arg2 noua pozitie y
; arg3 noua pozitie x
; arg4 vechea pozitie y
; arg5 vechea pozitie x
verif_move_is_en_passant proc
	push ebp
	mov ebp, esp

	
	cmp dword ptr [ebp + arg1], 5
	je verif_move_is_en_passant_black_pawn
	
	cmp dword ptr [ebp + arg1], 12
	je verif_move_is_en_passant_white_pawn
	; daca nu e pion atunci nu este en_passant
	jmp verif_move_is_en_passant_final
	
verif_move_is_en_passant_black_pawn:
	get_element_from_grid_macro dword ptr [ebp + arg3], dword ptr [ebp + arg2]
	cmp eax, 6
	jne verif_move_is_en_passant_final
	mov ecx, [ebp + arg3]
	sub ecx, [ebp + arg5]
	mov edx, [ebp + arg2]
	sub edx, [ebp + arg4]
	cmp ecx, 1
	jne verif_move_is_en_passant_final
	cmp edx, 1
	je verif_move_is_en_passant_black_pawn_true
	cmp edx, -1
	je verif_move_is_en_passant_black_pawn_true
	jmp verif_move_is_en_passant_final
	

verif_move_is_en_passant_black_pawn_true:
	set_element_to_grid_macro dword ptr [ebp + arg5], dword ptr [ebp + arg2], 6
	

verif_move_is_en_passant_white_pawn:
	get_element_from_grid_macro dword ptr [ebp + arg3], dword ptr [ebp + arg2]
	
	cmp eax, 6
	jne verif_move_is_en_passant_final
	mov ecx, [ebp + arg5]
	sub ecx, [ebp + arg3]
	mov edx, [ebp + arg4]
	sub edx, [ebp + arg2]
	cmp ecx, 1
	jne verif_move_is_en_passant_final
	cmp edx, 1
	je verif_move_is_en_passant_white_pawn_true
	cmp edx, -1
	je verif_move_is_en_passant_white_pawn_true
	jmp verif_move_is_en_passant_final
	
	
verif_move_is_en_passant_white_pawn_true:
	set_element_to_grid_macro dword ptr [ebp + arg5], dword ptr [ebp + arg2], 6

	
verif_move_is_en_passant_final:
	mov esp, ebp
	pop ebp
	ret 20
verif_move_is_en_passant endp
	
	

	
; functie care verifica drepturile la castle
;arg1 noua pozitie y
;arg2 noua pozitie x
;arg3 vechea pozitie y
;arg4 vechea pozitie x
check_castle_rights proc
	push ebp
	mov ebp, esp
	
	; verificam daca s-a mutat regele negru
check_castle_rights_black_king1:
	cmp dword ptr [ebp + arg4], 0
	jne check_castle_rights_black_king2
	cmp dword ptr [ebp + arg3], 4
	jne check_castle_rights_black_king2
	jmp check_castle_rights_king_black_wrong
	
check_castle_rights_black_king2:
	cmp dword ptr [ebp + arg2], 0
	jne check_castle_rights_black_left_rook1
	cmp dword ptr [ebp + arg1], 4
	jne check_castle_rights_black_left_rook1
	jmp check_castle_rights_king_black_wrong
	
check_castle_rights_king_black_wrong:
	mov can_big_castle_black, 0
	mov can_small_castle_black, 0
	
	
; verificam tura din stanga de culoare neagra
check_castle_rights_black_left_rook1:
	cmp dword ptr [ebp + arg4], 0
	jne check_castle_rights_black_left_rook2
	cmp dword ptr [ebp + arg3], 0
	jne check_castle_rights_black_left_rook2
	jmp check_castle_rights_black_left_rook_wrong
	
check_castle_rights_black_left_rook2:
	cmp dword ptr [ebp + arg2], 0
	jne check_castle_rights_black_right_rook1
	cmp dword ptr [ebp + arg1], 0
	jne check_castle_rights_black_right_rook1
	jmp check_castle_rights_black_left_rook_wrong
	
check_castle_rights_black_left_rook_wrong:
	mov can_big_castle_black, 0
	
	
; verificam tura din dreapta de culoare neagra
check_castle_rights_black_right_rook1:
	cmp dword ptr [ebp + arg4], 0
	jne check_castle_rights_black_right_rook2
	cmp dword ptr [ebp + arg3], 7
	jne check_castle_rights_black_right_rook2
	jmp check_castle_rights_black_right_rook_wrong
	
check_castle_rights_black_right_rook2:
	cmp dword ptr [ebp + arg2], 0
	jne check_castle_rights_white_king1
	cmp dword ptr [ebp + arg1], 7
	jne check_castle_rights_white_king1
	jmp check_castle_rights_black_right_rook_wrong
	
check_castle_rights_black_right_rook_wrong:
	mov can_small_castle_black, 0
	
	
	
	
		; verificam daca s-a mutat regele alb
check_castle_rights_white_king1:
	cmp dword ptr [ebp + arg4], 7
	jne check_castle_rights_white_king2
	cmp dword ptr [ebp + arg3], 4
	jne check_castle_rights_white_king2
	jmp check_castle_rights_king_white_wrong
	
check_castle_rights_white_king2:
	cmp dword ptr [ebp + arg2], 7
	jne check_castle_rights_white_left_rook1
	cmp dword ptr [ebp + arg1], 4
	jne check_castle_rights_white_left_rook1
	jmp check_castle_rights_king_white_wrong
	
check_castle_rights_king_white_wrong:
	mov can_big_castle_white, 0
	mov can_small_castle_white, 0
	
	
; verificam tura din stanga de culoare alba
check_castle_rights_white_left_rook1:
	cmp dword ptr [ebp + arg4], 7
	jne check_castle_rights_white_left_rook2
	cmp dword ptr [ebp + arg3], 0
	jne check_castle_rights_white_left_rook2
	jmp check_castle_rights_white_left_rook_wrong
	
check_castle_rights_white_left_rook2:
	cmp dword ptr [ebp + arg2], 7
	jne check_castle_rights_white_right_rook1
	cmp dword ptr [ebp + arg1], 0
	jne check_castle_rights_white_right_rook1
	jmp check_castle_rights_white_left_rook_wrong
	
check_castle_rights_white_left_rook_wrong:
	mov can_big_castle_white, 0
	
	
; verificam tura din dreapta de culoare alba
check_castle_rights_white_right_rook1:
	cmp dword ptr [ebp + arg4], 7
	jne check_castle_rights_white_right_rook2
	cmp dword ptr [ebp + arg3], 7
	jne check_castle_rights_white_right_rook2
	jmp check_castle_rights_white_right_rook_wrong
	
check_castle_rights_white_right_rook2:
	cmp dword ptr [ebp + arg2], 7
	jne check_castle_rights_final
	cmp dword ptr [ebp + arg1], 7
	jne check_castle_rights_final
	jmp check_castle_rights_white_right_rook_wrong
	
check_castle_rights_white_right_rook_wrong:
	mov can_small_castle_white, 0
	
	
check_castle_rights_final:
	mov esp, ebp
	pop ebp
	ret 16
check_castle_rights endp
	

	
	
; functie care verifica daca este miscare dubla a pionului
; arg1 piesa
; arg2 noua pozitie y
; arg3 noua pozitie x
; arg4 vechea pozitie y
; arg5 vechea pozitie x
check_double_move_pawn proc	
	push ebp
	mov ebp, esp
	
	cmp eax, 5
	je check_double_move_pawn_black
	cmp eax, 12
	je check_double_move_pawn_white
	jmp check_double_move_pawn_false
	
check_double_move_pawn_black:
	mov eax, [ebp + arg3]
	sub eax, [ebp + arg5]
	cmp eax, 2
	je check_double_move_pawn_true
	jmp check_double_move_pawn_false
	
check_double_move_pawn_white:
	mov eax, [ebp + arg5]
	sub eax, [ebp + arg3]
	cmp eax, 2
	je check_double_move_pawn_true
	jmp check_double_move_pawn_false
	
check_double_move_pawn_true:
	mov can_en_passant, 1
	mov eax, [ebp + arg3]
	mov en_passant_x, eax
	
	mov eax, [ebp + arg2]
	mov en_passant_y, eax
	jmp check_double_move_pawn_final
	
check_double_move_pawn_false:
	mov can_en_passant, 0
	mov en_passant_x, -1
	mov en_passant_y, -1
	jmp check_double_move_pawn_final
	
	
check_double_move_pawn_final:
	mov esp, ebp
	pop ebp
	ret 20
check_double_move_pawn endp
	
	
	
; functia care determina toate miscarile posibile ale unei piese de sah
; arg3 patrat_x
; arg2 patrat_y
; arg1 piece
get_all_possible_moves proc
	push ebp
	mov ebp, esp
	
	mov eax, 0
	mov ecx, [ebp + arg1]
	cmp ecx, 6
	je get_all_possible_moves_final
	
	mov ecx, 8
get_all_possible_moves_for1:
	mov esi, 8
	sub esi, ecx
	push ecx
	mov ecx, 8
	
get_all_possible_moves_for2:
	mov edi, 8
	sub edi, ecx
	
	push ecx
	
	push eax
	push esi
	push edi

	verif_move_macro dword ptr [ebp + arg3], dword ptr [ebp + arg2], esi, edi, dword ptr [ebp + arg1]

	cmp eax, 1
	
	pop edi
	pop esi
	pop eax
	jne get_all_possible_moves_continuare

	push eax
	push esi
	push edi
	
	is_pin_macro dword ptr [ebp + arg3], dword ptr [ebp + arg2], esi, edi, [ebp + arg1]

	cmp eax, 1
	pop edi
	pop esi
	pop eax
	je get_all_possible_moves_continuare

	
	mov available_cube_x[eax * 4], esi
	mov available_cube_y[eax * 4], edi
	inc eax
	
get_all_possible_moves_continuare:
	pop ecx
	loop get_all_possible_moves_for2
	pop ecx
	dec ecx
	cmp ecx, 0
	jg get_all_possible_moves_for1
	
get_all_possible_moves_final:
	mov available_cube_x[eax * 4], -1
	mov available_cube_y[eax * 4], -1

	mov esp, ebp
	pop ebp
	ret 12
get_all_possible_moves endp
	

	
	
; functia care verifica daca regele se afla in sah
; arg1 - ce rege este 0 - negru 7 - alb
verif_king_check proc
	push ebp
	mov ebp, esp
	

	find_the_king_macro dword ptr [ebp + arg1]
	mov eax, ecx
	mov ecx, 8
verif_king_check_for1:
	mov esi, 8
	sub esi ,ecx
	push ecx
	mov ecx, 8
verif_king_check_for2:
	mov edi, 8
	sub edi, ecx
	
	push ecx
	push eax
	push edx
	push esi
	push edi
	get_element_from_grid_macro esi, edi
	mov ecx, eax

	pop edi
	pop esi
	pop edx
	pop eax
	mov ebx, [ebp + arg1]
	
	
	cmp ebx, 0
	je verif_king_check_black
	
verif_king_check_white:
	cmp ecx, 6
	jge verif_king_dupa_verificare
	
	push eax
	push edx
	push esi
	push edi

	verif_move_macro esi, edi, eax, edx, ecx
	mov ecx, eax
	
	pop edi
	pop esi
	pop edx
	pop eax
	
	cmp ecx, 1
	je verif_king_check_true
	jmp verif_king_dupa_verificare
	
verif_king_check_black:
	cmp ecx, 6
	jle verif_king_dupa_verificare
	
	push eax
	push edx
	push esi
	push edi

	verif_move_macro esi, edi, eax, edx, ecx
	mov ecx, eax
	
	pop edi
	pop esi
	pop edx
	pop eax
	
	cmp ecx, 1
	je verif_king_check_true
	jmp verif_king_dupa_verificare

verif_king_dupa_verificare:

	pop ecx
	dec ecx
	cmp ecx, 0
	jg verif_king_check_for2
	
	pop ecx
	dec ecx
	cmp ecx, 0
	jg verif_king_check_for1
	
verif_king_check_false:
	mov eax, 0
	jmp verif_king_check_final
	
	
verif_king_check_true:

	mov eax, 1
	jmp verif_king_check_final

verif_king_check_final:
	mov esp, ebp
	pop ebp
	ret 4
verif_king_check endp
	
	
	
	
; functie care verifica daca este sah mat
; arg1 piesa 0 - rege negru; 7 - rege alb
verif_no_moves proc
	push ebp
	mov ebp, esp
	
	find_the_king_macro dword ptr [ebp + arg1]
	
	mov eax, ecx ; salvam in eax linia
	mov ebx, edx ; salvam in ebx coloana
	
	mov ecx, 8
verif_check_mate_for1:
	mov esi, 8
	sub esi, ecx
	
	push ecx
	mov ecx, 8
verif_check_mate_for2:


	mov edi, 8
	sub edi, ecx
	
	pusha ; salvam toate valorile din registrii
	
	get_element_from_grid_macro esi, edi
	
	push eax
	
	get_the_color_macro dword ptr [ebp + arg1]
	mov ebx, eax
	
	pop eax
	push eax
	
	get_the_color_macro eax
	
	cmp eax, ebx
	pop eax
	jne verif_check_mate_continuare_loop

	get_all_possible_moves_macro esi, edi, eax
	mov available_cube_x[0], -1
	mov available_cube_x[0], -1
	cmp eax, 0
	
	jg verif_check_mate_false
	
verif_check_mate_continuare_loop:
	popa
	loop verif_check_mate_for2
	pop ecx
	loop verif_check_mate_for1
	
	
verif_check_mate_true:
	mov eax, 1
	jmp verif_check_mate_final
	
verif_check_mate_false:
	mov eax, 0
	jmp verif_check_mate_final
	
verif_check_mate_final:
	mov esp, ebp
	pop ebp
	ret 4
verif_no_moves endp
	

	
	
; functia care realizeaza o miscare
; arg6 - old pos_x
; arg5 - old pos_y
; arg4 - new pos_x
; arg3 - new pos_y
; arg2 - old piece to move
; arg1 - replace piece
make_move proc
	push ebp
	mov ebp, esp
	
	set_element_to_grid_macro dword ptr [ebp + arg6], dword ptr [ebp + arg5], dword ptr [ebp + arg1]
	
	set_element_to_grid_macro dword ptr [ebp + arg4], dword ptr [ebp + arg3], dword ptr [ebp + arg2]
	
	mov esp, ebp
	pop ebp
	ret 24
make_move endp





; functia care verifica daca un pion a ajuns la final, caz in care il promovam la regina
; arg3 pos_x
; arg2 pos_y
; arg1 piece
verif_promovation proc
	push ebp
	mov ebp, esp
	
	mov ecx, [ebp + arg1]
	cmp ecx, 5
	je verif_promovation_pion_negru
	cmp ecx, 12
	je verif_promovation_pion_alb
	jmp verif_promovation_false
	
verif_promovation_pion_negru:
	mov ecx, [ebp + arg3]
	cmp ecx, 7
	je verif_promovation_true
	jmp verif_promovation_false
	
verif_promovation_pion_alb:
	mov ecx, [ebp + arg3]
	cmp ecx, 0
	je verif_promovation_true
	jmp verif_promovation_false
	
	
verif_promovation_true:
	mov eax, 1
	jmp verif_promovation_final
	
verif_promovation_false:
	mov eax, 0
	jmp verif_promovation_final
	
verif_promovation_final:
	mov esp, ebp
	pop ebp
	ret 12
verif_promovation endp




; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - y (in cazul apasarii unei taste, y contine codul ascii al tastei care a fost apasata)
; arg3 - x
draw proc
	push ebp
	mov ebp, esp
	pusha

	cmp end_game, 1
	je resetare_joc
	
	mov eax, [ebp + arg1]
	cmp eax, 0
	je initializare_joc
	cmp eax, 1
	je click_mouse
	cmp eax, 2
	je desenare_grid
	jmp final_draw

click_mouse: ; mai intai verificam daca a fost apasat click si apoi afisam 
	click_handle_macro dword ptr [ebp + arg3], dword ptr [ebp + arg2]
	jmp desenare_grid
	
initializare_joc:
	call get_table_from_file
	
desenare_grid: ; desenam mereu gridul daca nu a fost apasat
	draw_grid_macro
	draw_pieces_macro
	jmp final_draw
	
resetare_joc:
	mov eax, [ebp + arg1]
	cmp eax, 3
	je verificare_tasta_apasata
	jmp final_draw
	
verificare_tasta_apasata:
	cmp dword ptr [ebp + arg2], 'R'
	jne final_draw
	
	reset_the_game_macro
	
	jmp final_draw
	
	
	
final_draw:

	popa
	mov esp, ebp
	pop ebp
	ret
draw endp


; functie care reseteaza jocului
reset_the_game proc
	push ebp
	mov ebp, esp
	
	mov ecx, 8
reset_the_game_for1:
	mov esi, 8
	sub esi, ecx
	
	push ecx
	mov ecx, 8
reset_the_game_for2:
	mov edi, 8
	sub edi, ecx
	
	mov eax, esi
	mov ebx, 8
	mul ebx
	
	add eax, edi
	
	push ecx
	mov ecx, table_pieces_initially[eax * 4]
	mov table_pieces[eax * 4], ecx
	pop ecx
	loop reset_the_game_for2
	pop ecx
	loop reset_the_game_for1
	
	mov end_game, 0
	mov check_mate_x, -1
	mov check_mate_y, -1
	mov stalemate_x1, -1
	mov stalemate_x2, -1
	mov stalemate_y1, -1
	mov stalemate_y2, -1
	mov piece_selected, 6
	mov piece_selected_x, -1
	mov piece_selected_y, -1
	mov cube_selected_x, -1
	mov cube_selected_y, -1
	mov white_to_move, 1
	mov available_cube_x[0], -1
	mov available_cube_y[0], -1
	mov can_move, 0
	
	mov esp, ebp
	pop ebp
	ret
reset_the_game endp




; functia care seteaza un element de pe pozitia (x, y) cu o anumita valoare, cu conventia stdcall
; arg1 valoarea
; arg2 coloana
; arg3 linia
set_element_to_grid proc

	push ebp
	mov ebp, esp
	
	mov eax, [ebp + arg3]
		
	mov ecx, 8
	mul ecx
	mov ecx, eax
	
	mov eax, [ebp + arg2]
	mov edx, 4
	mul edx
	mov edx, eax

	mov eax, [ebp + arg1]


	
	mov table_pieces[ecx * 4 + edx], eax
	mov esp, ebp
	pop ebp
	
	ret 12
	
set_element_to_grid endp





; functia care returneaza in eax ce element se afla pe pozitia (x, y) cu conventia stdcall
; arg1 coloana
; arg2 linia

get_element_from_grid proc
	push ebp
	mov ebp, esp
	mov eax, [ebp + arg2]
	mov ecx, 8
	mul ecx
	mov ecx, eax
	

	add ecx, [ebp + arg1]


	mov eax, table_pieces[ecx * 4]

	mov esp, ebp
	pop ebp
	
	ret 8
get_element_from_grid endp





; functia care determina pozitia in care se afla o coordonata de pe grid, in ce patrat se afla, cu stdcall
; arg1 - coloana
; arg2 - linie
; ca rezultate avem: eax - al catelea cub este
;					 ecx - linia
; 					 edx - coloana

get_cube proc
	
	push ebp
	mov ebp, esp
	
	mov eax, [ebp+arg1]	
	mov edx, 0
	mov ecx, cube_width
	div ecx
	push eax
	
	mov eax, [ebp + arg2]
	mov edx, 0
	mov ecx, cube_height
	div ecx
	
	
	push eax
	
	pop ecx
	pop edx
	mov eax, ecx
	add eax, edx
	
	mov esp, ebp
	pop ebp
	ret 8
get_cube endp





; verificam daca coloram patratul galben
; arg1 cube_y
; arg2 cube_x
verificare_este_patrat_available proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ecx, 50
verificare_este_patrat_available_for:
	mov esi, 50
	sub esi, ecx
	mov ebx, [ebp + arg1]
	mov eax, [ebp + arg2]
	cmp available_cube_x[esi * 4], -1
	je verificare_este_patrat_available_fals
	cmp available_cube_y[esi * 4], -1
	je verificare_este_patrat_available_fals
	cmp eax, available_cube_x[esi * 4]
	jne verificare_este_patrat_available_for_continuare
	cmp ebx, available_cube_y[esi * 4]
	jne verificare_este_patrat_available_for_continuare
	jmp verificare_este_patrat_available_adevarat
	
verificare_este_patrat_available_for_continuare:
	loop verificare_este_patrat_available_for
	
	
verificare_este_patrat_available_fals:
	popa
	mov eax, 0
	jmp verificare_este_patrat_available_final
	
verificare_este_patrat_available_adevarat:
	popa
	mov eax, 1
	jmp verificare_este_patrat_available_final
	
verificare_este_patrat_available_final:
	mov esp, ebp
	pop ebp
	ret 8
verificare_este_patrat_available endp



	
	
; functie care verifica daca o miscare este pin sau nu
; arg1 numarul piesei
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
is_pin proc
	push ebp
	mov ebp, esp
	
	
	mov eax, [ebp + arg1]
	
	cmp eax, 6 ; daca nu e piesa atunci iesim
	je is_pin_final
	jg verificare_pin_rege_alb ; verificam pentru regele alb
	
verificare_pin_rege_negru: ; verificam pentru regele negru
	get_element_from_grid_macro dword ptr [ebp + arg3], dword ptr [ebp + arg2]
	push eax
	make_move_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1], 6
	
	verif_king_check_macro 0
	
	mov ebx, eax
	pop eax
	push ebx
	

	make_move_macro [ebp + arg3], [ebp + arg2], [ebp + arg5], [ebp + arg4], [ebp + arg1], eax
	
	pop ebx
	cmp ebx, 1
	jne is_pin_false
	jmp is_pin_true
	
	
verificare_pin_rege_alb:
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	push eax
	
	make_move_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1], 6
	
	verif_king_check_macro 7
	
	mov ebx, eax
	pop eax
	push ebx
	

	make_move_macro [ebp + arg3], [ebp + arg2], [ebp + arg5], [ebp + arg4], [ebp + arg1], eax
	
	pop ebx
	cmp ebx, 1
	jne is_pin_false
	jmp is_pin_true
	
	
is_pin_false:
	mov eax, 0
	jmp is_pin_final
	
is_pin_true:
	mov eax, 1
	jmp is_pin_final
	
is_pin_final:
	mov esp, ebp
	pop ebp
	ret 20
is_pin endp
	


	

; functie pentru verificarea unei noi pozitii pentru o miscare
; arg1 numarul piesei
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
verif_move proc

	push ebp
	mov ebp, esp

verificare_fiecare_piesa:
	mov eax, [ebp + arg1]
	cmp eax, 0
	je rege
	cmp eax, 1
	je regina
	cmp eax, 2
	je tura
	cmp eax, 3
	je cal
	cmp eax, 4
	je nebun
	cmp eax, 5
	je pion_negru
	cmp eax, 7
	je rege
	cmp eax, 8
	je regina
	cmp eax, 9
	je tura
	cmp eax, 10
	je cal
	cmp eax, 11
	je nebun
	cmp eax, 12
	je pion_alb
	mov eax, 0
	jmp final_verif_move
	
rege:
	verif_move_king_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	jmp final_verif_move
	
regina: 
	verif_move_queen_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	jmp final_verif_move

tura:
	verif_move_rook_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	jmp final_verif_move
	
cal:
	verif_move_knight_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	jmp final_verif_move
	
nebun:
	verif_move_bishop_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	jmp final_verif_move

	
	
pion_negru:
	verif_move_pawn_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], 0
	jmp final_verif_move
	


pion_alb:
	verif_move_pawn_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], 1
	jmp final_verif_move
	
	
final_verif_move:

	mov esp, ebp
	pop ebp
	ret 20
	
verif_move endp





; functie pentru verificarea unei miscari a unui pion
; arg1 culoare, 1 - alb, 0 - negru
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
verif_move_pawn proc
	push ebp
	mov ebp, esp

	mov eax, [ebp + arg1]
	cmp eax, 1
	je pion_culoare_alba

pion_culoare_neagra:

	mov eax, [ebp + arg4]
	cmp [ebp + arg2], eax
	jne verif_move_pawn_black_capture ; daca nu avem liniile egale, atunci s-ar putea sa capturepe pe diagonala

	mov eax, [ebp + arg5]
	cmp eax, 1
	jne verificare_miscare_simpla_pion_negru ; daca nu se afla pionul negru pe pozitia 1 atunci el nu poate avansa de 2 ori
	mov ecx, [ebp + arg3]
	sub ecx, eax
	cmp ecx, 2 ; verificam daca a diferenta dintre noua coloana si vechea este 2
	jne verificare_miscare_simpla_pion_negru
	
	get_element_from_grid_macro 2, [ebp + arg2]
	cmp eax, 6
	jne verif_move_pawn_false
	
	get_element_from_grid_macro 3, [ebp + arg2]
	cmp eax, 6
	je verif_move_pawn_true
	
	
	
verificare_miscare_simpla_pion_negru:
	mov ecx, [ebp + arg3]
	mov edx, [ebp + arg5]
	sub ecx, edx
	cmp ecx, 1
	jne verif_move_pawn_false ; daca diferenta este mai mare de 1 unitate afisam fals
	
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	
	cmp eax, 6 ; verificam daca pe noua pozitie este gol ca sa punem pionul
	je verif_move_pawn_true
	jmp verif_move_pawn_false
	
verif_move_pawn_black_capture:

	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	cmp eax, 6 ; daca este o piesa neagra sau goala atunci nu putem captura
	;jge verif_move_pawn_black_capture_en_passant
	jl verif_move_pawn_false

	mov ecx, [ebp + arg3]
	mov edx, [ebp + arg5]
	sub ecx, edx
	cmp ecx, 1; verificam daca diferenta dintre randuri e 1
	jne verif_move_pawn_false
	mov ecx, [ebp + arg2]
	mov edx, [ebp + arg4]
	sub ecx, edx
	cmp ecx, 1 ; verificam daca diferenta dintre coloane e +- 1
	je verif_move_pawn_black_capture_decision
	cmp ecx, -1
	je verif_move_pawn_black_capture_decision
	jmp verif_move_pawn_false
	
verif_move_pawn_black_capture_decision:
	cmp eax, 6
	je verif_move_pawn_black_capture_en_passant
	jg verif_move_pawn_true
	

	
verif_move_pawn_black_capture_en_passant:
; pusha
; push [ebp + arg2]
; push [ebp + arg3]
; push offset format2
; call printf
; add esp, 12
; popa
	mov ecx, [ebp + arg3]
	mov edx, [ebp + arg2]
	cmp can_en_passant, 0
	je verif_move_pawn_false
	cmp edx, en_passant_y
	jne verif_move_pawn_false
	mov eax, ecx
	sub eax, en_passant_x
	cmp eax, 1
	je verif_move_pawn_true
	jmp verif_move_pawn_false
	
; verif_move_pawn_black_capture_en_passant_set_en_passant:
	; mov en_passant_done, 1
	; jmp verif_move_pawn_true

	
; la fel si la pionul alb, doar ca tinem cont ca acesta merge catre randuri mai mici deci trebuie sa inversam
; diferentele pe care le-am facut la pionul negru
pion_culoare_alba:

	mov eax, [ebp + arg4]
	cmp [ebp + arg2], eax
	jne verif_move_pawn_white_capture

	mov eax, [ebp + arg5]
	cmp eax, 6
	jne verificare_miscare_simpla_pion_alb
	mov ecx, [ebp + arg3]
	sub eax, ecx
	cmp eax, 2
	jne verificare_miscare_simpla_pion_alb
	
	get_element_from_grid_macro 5, [ebp + arg2]
	
	cmp eax, 6
	jne verif_move_pawn_false
	
	get_element_from_grid_macro 4, [ebp + arg2]
	
	cmp eax, 6
	je verif_move_pawn_true
	
verificare_miscare_simpla_pion_alb:
	mov ecx, [ebp + arg5]
	mov edx, [ebp + arg3]
	sub ecx, edx
	cmp ecx, 1
	jne verif_move_pawn_false
	
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	
	cmp eax, 6
	je verif_move_pawn_true
	jmp verif_move_pawn_false
	
	
verif_move_pawn_white_capture:

	get_element_from_grid_macro [ebp + arg3], [ebp + arg2] ; daca piesa este alba atunci nu o putem captura
	cmp eax, 6
	jg verif_move_pawn_false
	
	mov ecx, [ebp + arg3] ; punem in ecx noua linie
	mov edx, [ebp + arg5] ; scadem vechea linie
	sub ecx, edx
	cmp ecx, -1 ; daca nu este -1 atunci este miscare ilegala
	jne verif_move_pawn_false
	
	
	mov ecx, [ebp + arg2]
	mov edx, [ebp + arg4]
	sub ecx, edx
	cmp ecx, 1
	je verif_move_pawn_white_capture_decision
	cmp ecx, -1
	je verif_move_pawn_white_capture_decision
	jmp verif_move_pawn_false
	
	
verif_move_pawn_white_capture_decision:
	cmp eax, 6
	je verif_move_pawn_white_capture_en_passant
	jl verif_move_pawn_true
	

	
verif_move_pawn_white_capture_en_passant:
	mov ecx, [ebp + arg3]
	mov edx, [ebp + arg2]
	cmp can_en_passant, 0
	je verif_move_pawn_false
	cmp edx, en_passant_y
	jne verif_move_pawn_false
	mov eax, en_passant_x
	sub eax, ecx
	cmp eax, 1
	je verif_move_pawn_true
	jmp verif_move_pawn_false
	
; verif_move_pawn_white_capture_en_passant_set_en_passant:
	; mov en_passant_done, 1
	; jmp verif_move_pawn_true
	
	
	
verif_move_pawn_false:
	mov eax, 0
	jmp verif_move_pawn_final
verif_move_pawn_true:
	mov eax, 1

verif_move_pawn_final:	
	mov esp, ebp
	pop ebp
	ret 20

verif_move_pawn endp
	

	
	
; functie pentru verificarea unei miscari a unui cal
; arg1 piesa
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
verif_move_knight proc
	push ebp
	mov ebp, esp
	
	
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]

	get_the_color_macro eax
	
	mov esi, eax
	
	get_the_color_macro [ebp + arg1]
	cmp eax, esi
	je verif_move_knight_false
	
	
	; calul se muta 2 pozitii intr-o parte si una in alta 
	; verificam cele 4 moduri de a avea diferenta 2 intre noua pozitie si vechea pozitie
	
	
	
	mov ecx, [ebp + arg5]
	mov edx, [ebp + arg4]
	add ecx, 2
	cmp ecx, [ebp + arg3]
	
	je verif_move_knight1 ; trebuie doar sa verificam coloanele
	pusha
	mov ecx, [ebp + arg5]
	mov edx, [ebp + arg4]
	sub ecx, 2
	cmp ecx, [ebp + arg3]
	je verif_move_knight1 ; trebuie doar sa verificam coloanele

	mov ecx, [ebp + arg5]
	mov edx, [ebp + arg4]
	add edx, 2
	cmp edx, [ebp + arg2]
	je verif_move_knight2 ; trebuie doar sa verificam liniile
	
	mov ecx, [ebp + arg5]
	mov edx, [ebp + arg4]
	sub edx, 2
	cmp edx, [ebp + arg2]
	je verif_move_knight2 ; trebuie doar sa verificam liniile
	jmp verif_move_knight_false
	
verif_move_knight1:
; verificam daca diferenta dintre coloane este +- 1 doareace stim ca liniile au o diferenta de 2
	sub edx, [ebp + arg2]

	cmp edx, 1
	je verif_move_knight_true

	cmp edx, -1
	je verif_move_knight_true
	jmp verif_move_knight_false

verif_move_knight2:
; verificam daca diferenta dintre linii este +- 1 doareace stim ca coloanele au o diferenta de 2
	sub ecx, [ebp + arg3]
	cmp ecx, 1
	je verif_move_knight_true
	cmp ecx, -1
	je verif_move_knight_true
	jmp verif_move_knight_false
	
verif_move_knight_true:

	mov eax, 1

	jmp verif_move_knight_final

verif_move_knight_false:
	mov eax, 0
	
	
verif_move_knight_final:
	mov esp, ebp
	pop ebp
	ret 16
	
	
verif_move_knight endp
	


	
	
; functie pentru verificarea unei miscari a turei
; arg1 piesa
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
; in eax returneaza 1 daca e corecta miscarea si 0 daca nu
verif_move_rook proc
	push ebp
	mov ebp, esp
	
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	
	get_the_color_macro eax
	
	mov esi, eax
	get_the_color_macro [ebp + arg1]
	cmp eax, esi
	je verif_move_rook_false
	
	mov eax, [ebp + arg2]
	cmp eax, [ebp + arg4]
	je verif_move_rook_col_egale ; verificam daca avem coloane egale
	
	mov eax, [ebp + arg3]
	cmp eax, [ebp + arg5]
	je verif_move_rook_row_egale ; verificam daca avem linii egale
	jmp verif_move_rook_false ; daca nu avem cel putin una atunci miscarea e falsa
	
verif_move_rook_col_egale: ; verificam daca intre linii se afla un element
	mov ecx, [ebp + arg3]
	mov edx, [ebp + arg5]
	mov esi, ecx
	mov edi, edx
	cmp ecx, edx
	jge verif_move_rook_col_egale__dupa_exchange
	mov edi, ecx ; in esi punem valoarea cea mai mare
	mov esi, edx ; in edi punem valoarea mai mica
	
verif_move_rook_col_egale__dupa_exchange:
	mov ecx, esi
	sub ecx, edi
	dec ecx ; trebuie sa eliminam noua pozitie din calcul
cmp ecx, 0 ; daca vrem sa mutam doar o pozitie se poate
je verif_move_rook_true
verif_move_rook_col_egale_for_loop:
	push ecx
	add ecx, edi
	mov edx, [ebp + arg2]
	
	get_element_from_grid_macro ecx, edx
	
	pop ecx
	cmp eax, 6 ; verificam daca nu este nicio piesa intre ele
	jne verif_move_rook_false
	loop verif_move_rook_col_egale_for_loop
	jmp verif_move_rook_true ; daca am iesit din loop miscarea e corecta
	

verif_move_rook_row_egale:
	mov ecx, [ebp + arg2]
	mov edx, [ebp + arg4]
	cmp ecx, edx
	mov esi, ecx
	mov edi, edx
	jge verif_move_rook_row_egale__dupa_exchange
	mov edi, ecx ; in esi punem valoarea cea mai mare
	mov esi, edx ; in edi punem valoarea mai mica
	
verif_move_rook_row_egale__dupa_exchange:
	mov ecx, esi
	sub ecx, edi
	dec ecx
	cmp ecx, 0
	je verif_move_rook_true
verif_move_rook_row_egale_for_loop:
	push ecx
	add ecx, edi
	mov edx, [ebp + arg3]
	
	get_element_from_grid_macro edx, ecx
	
	pop ecx
	cmp eax, 6
	jne verif_move_rook_false
	loop verif_move_rook_row_egale_for_loop
	jmp verif_move_rook_true

		
verif_move_rook_false:
	mov eax, 0
	jmp verif_move_rook_final
	
verif_move_rook_true:
	mov eax, 1
	
verif_move_rook_final:
	mov esp, ebp
	pop ebp
	ret 16
	
verif_move_rook endp
	

	

; functie pentru verificarea unei miscari al nebunului
; arg1 culoarea
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
; in eax returneaza 1 daca e corecta miscarea si 0 daca nu		
verif_move_bishop proc
	push ebp
	mov ebp, esp
	
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	
	get_the_color_macro eax
	
	mov esi, eax
	
	get_the_color_macro [ebp + arg1]
	
	cmp eax, esi
	je verif_move_bishop_false
	
	mov ecx, [ebp + arg2]
	sub ecx, [ebp + arg4]
	mov edx, [ebp + arg3]
	sub edx, [ebp + arg5]
	mov esi, [ebp + arg5]
	mov edi, [ebp + arg4]
	
	cmp ecx, edx
	je verif_move_bishop_same_direction
	mov eax, ecx
	add eax, edx
	cmp eax, 0
	je verif_move_bishop_different_direction
	jmp verif_move_bishop_false
	
verif_move_bishop_same_direction:
	cmp ecx, 0
	jl verif_move_bishop_same_direction_1 ; se scade
	jg verif_move_bishop_same_direction_2 ; se aduna
	jmp verif_move_bishop_false
	
verif_move_bishop_different_direction:
	cmp edx, 0
	jl verif_move_bishop_same_direction_3 ; se scade la coloane si la linii se aduna
	jg verif_move_bishop_same_direction_4 ; se aduna la coloane si la linii se scade
	jmp verif_move_bishop_false
	
verif_move_bishop_same_direction_1:
	mov ecx, 0
	sub ecx, edx
	dec ecx
	cmp ecx, 0
	je verif_move_bishop_true
verif_move_bishop_same_direction_1_loop:
	push esi
	sub esi, ecx
	push edi
	sub edi, ecx
	push ecx
	
	get_element_from_grid_macro esi, edi
	
	pop ecx
	pop edi
	pop esi
	cmp eax, 6
	jne verif_move_bishop_false
	loop verif_move_bishop_same_direction_1_loop
	jmp verif_move_bishop_true
	
verif_move_bishop_same_direction_2:
	dec ecx
	cmp ecx, 0
	je verif_move_bishop_true
verif_move_bishop_same_direction_2_loop:
	push esi
	add esi, ecx
	push edi
	add edi, ecx
	push ecx
	
	get_element_from_grid_macro esi, edi

	pop ecx
	pop edi
	pop esi
	cmp eax, 6
	jne verif_move_bishop_false
	loop verif_move_bishop_same_direction_2_loop
	jmp verif_move_bishop_true
	
verif_move_bishop_same_direction_3:
	dec ecx
	cmp ecx, 0
	je verif_move_bishop_true
verif_move_bishop_same_direction_3_loop:
	push esi
	sub esi, ecx
	push edi
	add edi, ecx
	push ecx
	
	get_element_from_grid_macro esi, edi
	
	pop ecx
	pop edi
	pop esi
	cmp eax, 6
	jne verif_move_bishop_false
	loop verif_move_bishop_same_direction_3_loop
	jmp verif_move_bishop_true

verif_move_bishop_same_direction_4:
	mov ecx, edx
	dec ecx
	cmp ecx, 0
	je verif_move_bishop_true
verif_move_bishop_same_direction_4_loop:
	push esi
	add esi, ecx
	push edi
	sub edi, ecx
	push ecx
	
	get_element_from_grid_macro esi, edi
	
	pop ecx
	pop edi
	pop esi
	cmp eax, 6
	jne verif_move_bishop_false
	loop verif_move_bishop_same_direction_4_loop
	jmp verif_move_bishop_true
	
verif_move_bishop_true:
	mov eax, 1
	jmp verif_move_bishop_final
	
verif_move_bishop_false:
	mov eax, 0
	jmp verif_move_bishop_final
	
verif_move_bishop_final:
	mov esp, ebp
	pop ebp
	ret 16
verif_move_bishop endp
	

	
	
	
; functie pentru verificarea unei miscari a reginei
; arg1 piesa
; arg1 noua pozitie coloana
; arg2 noua pozitie linie
; arg3 vechea pozitie coloana
; arg4 vechea pozitie linie
; in eax returneaza 1 daca e corecta miscarea si 0 daca nu	
verif_move_queen proc
	push ebp
	mov ebp, esp
	
	
	verif_move_rook_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	
	cmp eax, 1
	je verif_move_queen_final
		
	
	verif_move_bishop_macro [ebp + arg5], [ebp + arg4], [ebp + arg3], [ebp + arg2], [ebp + arg1]
	
	
	
verif_move_queen_final:
	mov esp, ebp
	pop ebp
	ret 16
verif_move_queen endp
	
; functie pentru verificarea unei miscari a turei
; arg1 piesa
; arg2 noua pozitie coloana
; arg3 noua pozitie linie
; arg4 vechea pozitie coloana
; arg5 vechea pozitie linie
; in eax returneaza 1 daca e corecta miscarea si 0 daca nu	
verif_move_king proc

	push ebp
	mov ebp, esp
	
	
	get_element_from_grid_macro [ebp + arg3], [ebp + arg2]
	
	get_the_color_macro eax
	
	mov esi, eax
	
	get_the_color_macro [ebp + arg1]
	
	cmp eax, esi
	je verif_move_king_castle
	
	mov ecx, [ebp + arg2]
	sub ecx, [ebp + arg4]
	mov edx, [ebp + arg3]
	sub edx, [ebp + arg5]

	cmp ecx, -1
	jl verif_move_king_castle
	cmp ecx, 1
	jg verif_move_king_castle
	cmp edx, -1
	jl verif_move_king_castle
	cmp edx, 1
	jg verif_move_king_castle
	cmp ecx, 0
	jne verif_move_king_true
	cmp edx, 0
	je verif_move_king_castle
	jmp verif_move_king_true
	
	
verif_move_king_castle:
	cmp dword ptr [ebp + arg1], 0
	je verif_move_king_castle_black_king
	
verif_move_king_castle_white_king:
	
	cmp eax, 1
	je verif_move_king_false
	
	cmp dword ptr [ebp + arg5], 7
	jne verif_move_king_false
	cmp dword ptr [ebp + arg4], 4
	jne verif_move_king_false
	
	; verificam rocada mica
verif_move_king_castle_white_king_small_castle:
	cmp dword ptr [ebp + arg3], 7
	jne verif_move_king_castle_white_king_big_castle
	cmp dword ptr [ebp + arg2], 6
	jne verif_move_king_castle_white_king_big_castle
	
	
	get_element_from_grid_macro 7, 5
	
	cmp eax, 6
	jne verif_move_king_false
	
	get_element_from_grid_macro 7, 6
	cmp eax, 6
	jne verif_move_king_false
	
	cmp can_small_castle_white, 1
	jne verif_move_king_false
	jmp verif_move_king_true
	
verif_move_king_castle_white_king_big_castle:
	cmp dword ptr [ebp + arg3], 7
	jne verif_move_king_false
	cmp dword ptr [ebp + arg2], 2
	jne verif_move_king_false
	

	get_element_from_grid_macro 7, 3
	cmp eax, 6
	jne verif_move_king_false
	
	get_element_from_grid_macro 7, 2
	cmp eax, 6
	jne verif_move_king_false
	
	get_element_from_grid_macro 7, 1
	cmp eax, 6
	jne verif_move_king_false
	
	cmp can_big_castle_white, 1
	jne verif_move_king_false
	jmp verif_move_king_true
	
	
verif_move_king_castle_black_king:
	cmp eax, 1
	je verif_move_king_false
	
	cmp dword ptr [ebp + arg5], 0
	jne verif_move_king_false
	cmp dword ptr [ebp + arg4], 4
	jne verif_move_king_false
	; verificam rocada mica
verif_move_king_castle_black_king_small_castle:
	cmp dword ptr [ebp + arg3], 0
	jne verif_move_king_castle_black_king_big_castle
	cmp dword ptr [ebp + arg2], 6
	jne verif_move_king_castle_black_king_big_castle
	
	get_element_from_grid_macro 0, 5
	cmp eax, 6
	jne verif_move_king_false
	
	get_element_from_grid_macro 0, 6
	cmp eax, 6
	jne verif_move_king_false
	
	cmp can_small_castle_black, 1
	jne verif_move_king_false
	jmp verif_move_king_true
	
verif_move_king_castle_black_king_big_castle:
	cmp dword ptr [ebp + arg3], 0
	jne verif_move_king_false
	cmp dword ptr [ebp + arg2], 2
	jne verif_move_king_false
	
	get_element_from_grid_macro 0, 3
	cmp eax, 6
	jne verif_move_king_false

	get_element_from_grid_macro 0, 2
	cmp eax, 6
	jne verif_move_king_false
	
	get_element_from_grid_macro 0, 1
	cmp eax, 6
	jne verif_move_king_false
	
	cmp can_big_castle_black, 1
	jne verif_move_king_false
	jmp verif_move_king_true
	
verif_move_king_true:
	mov eax, 1
	jmp verif_move_king_final
	
verif_move_king_false:
	mov eax, 0
	jmp verif_move_king_final
	
	
verif_move_king_final:
	mov esp, ebp
	pop ebp
	ret 16
verif_move_king endp
	

	
	
; functie care gaseste coordonata regelui
; arg1 culoarea 0 - negru 7 - alb
find_the_king proc

	push ebp
	mov ebp, esp
	

	lea eax, table_pieces
	mov ecx, 8
find_the_king_for_loop_rows:
	mov esi, 8
	sub esi, ecx
	push ecx
	mov ecx, 8
find_the_king_for_loop_cols:
	mov edi, 8
	sub edi, ecx
	mov edx, [ebp + arg1]
	cmp dword ptr[eax], edx
	jne continuare_find_the_king
	pop ecx
	mov ecx, esi
	mov edx, edi
	jmp final_find_the_king
	
continuare_find_the_king:
	add eax, 4
	loop find_the_king_for_loop_cols
	pop ecx
	loop find_the_king_for_loop_rows
	
	mov ecx, -1
	mov edx, -1
	
final_find_the_king:
	mov esp, ebp
	pop ebp
	ret 4
find_the_king endp
	

	
	
; functie care pune in eax 1 pt alb si 0 pt negru
; arg1 piesa 
get_the_color proc
	push ebp
	mov ebp, esp
	
	mov ecx, [ebp + arg1]
	cmp ecx, 6
	je piesa_lipsa
	jg piesa_alba
piesa_neagra:
	mov eax, 0
	jmp get_the_color_final

piesa_alba:
	mov eax, 1
	jmp get_the_color_final
	
piesa_lipsa:
	mov eax, -1
	
get_the_color_final:
	mov esp, ebp
	pop ebp
	ret 4
get_the_color endp
	


get_table_from_file proc
	push ebp
	mov ebp, esp
	
	push offset file_init_mode
	push offset file_init
	call fopen
	add esp, 8
	mov file_init_pointer, eax

	
	mov ecx, 8
get_table_from_file_for1:
	mov esi, 8
	sub esi, ecx
	push ecx
	mov ecx, 8
get_table_from_file_for2:

	mov edi, 8
	sub edi, ecx

	pusha
	push offset variable
	push offset file_init_msj
	push file_init_pointer
	call fscanf
	add  esp, 12 

	set_element_to_grid_macro esi, edi, variable

	popa
	loop get_table_from_file_for2
	pop ecx
	loop get_table_from_file_for1
	
	push offset can_big_castle_black
	push offset can_small_castle_black
	push offset can_small_castle_white
	push offset can_big_castle_white
	
	push offset en_passant_y
	push offset en_passant_x
	push offset can_en_passant
	
	push offset stalemate_y2
	push offset stalemate_y1
	push offset stalemate_x2
	push offset stalemate_x1
	
	push offset check_mate_y
	push offset check_mate_x
	push offset end_game
	
	push offset white_to_move
	push offset file_init_msj1
	push file_init_pointer
	call fscanf
	add  esp, 64

	push file_init_pointer
	call fclose
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
get_table_from_file endp

	
	
set_table_to_file proc
	push ebp
	mov ebp, esp
	
	push offset file_init_mode1
	push offset file_init
	call fopen
	add esp, 8
	mov file_init_pointer, eax
	mov ecx, 8
set_table_to_file_for1:
	mov esi, 8
	sub esi, ecx
	push ecx
	mov ecx, 8
set_table_to_file_for2:

	mov edi, 8
	sub edi, ecx

	pusha

	get_element_from_grid_macro esi, edi
	mov variable, eax
	push variable
	push offset file_init_msj2
	push file_init_pointer
	call fprintf
	add  esp, 12
	popa
	
	loop set_table_to_file_for2
	pop ecx
	push ecx
	push offset format1
	push file_init_pointer
	call fprintf
	add esp, 8
	pop ecx
	loop set_table_to_file_for1
	
	push offset format1
	push file_init_pointer
	call fprintf
	add esp, 8
	
	push can_big_castle_black
	push can_small_castle_black
	push can_small_castle_white
	push can_big_castle_white
	
	push en_passant_y
	push en_passant_x
	push can_en_passant
	
	push stalemate_y2
	push stalemate_y1
	push stalemate_x2
	push stalemate_x1
	
	push check_mate_y
	push check_mate_x
	push end_game
	
	push white_to_move
	push offset file_init_msj3
	push file_init_pointer
	call fprintf
	add  esp, 64

	push file_init_pointer
	call fclose
	add esp, 4
	
	mov esp, ebp
	pop ebp
	ret
set_table_to_file endp
	
	
	
start:	

	;alocam memorie pentru zona de desenat
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2 
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start
