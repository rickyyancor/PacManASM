.model large
.stack 128
.data 
textomenu db 'Menu',10,13,'1. Iniciar Sesion',10,13,'2. Registrar',10,13,'3. Salir',10,13,'$'
textoingresar db 10,13,'Ingrese Usuario Enter y su password',10,13,'$'
textoregistro db 10,13,'Registro de nuevo usuario',10,13,'ingrese usuario enter luego su password enter y repita su password',10,13,'$'
textoerrorarchivo db 10,13,'Ha habido un error con el archivo ',10,13,'$'
textoerrorarchivocerrar db 10,13,'Ha habido un error cerrando el archivo ',10,13,'$'
textoerrorarchivoleer db 10,13,'Ha habido un error leyendo el archivo ',10,13,'$'
textoerrorarchivoescribir db 10,13,'Ha habido un error escribiendo el archivo ',10,13,'$'
textonoexiste db 10,13,'Ha habido un error iniciando sesion usuario incorrecto ',10,13,'$'
textonoexistecontra db 10,13,'Ha habido un error iniciando sesion password incorrecto ',10,13,'$'
textorequisitocontra db 10,13, "el password debe de ser de 5 caracteres",10,13,'$'
textoingresoincorrecto db 10,13,'ha ingresado mal los datos ',10,13,'$'
textousuarioexiste db 10,13,'El usuario ya existe ',10,13,'$'
textousuariocreado db 10,13,'Usuario Creado ',10,13,'$'
textomenujuego db 10,13,'Sesion Iniciada',10,13,'Menu Juego ',10,13,'1--Iniciar Juego',10,13,'2--Retornar al juego',10,13,'3--Limpiar Juego ',10,13,'4--LogOut ',10,13,'$'
matriz db 500 dup ('9')
segundoactual db 0
usuarioactual db 0
i db ?
j db ?
x dw ?
tmp dw ?
inicialx dw ?
inicialy dw ?
posicionx dw ?
posiciony dw ?
pospacman dw ?
direccionpacman db ?
archivousuario db 'usuarios.txt',0
buffer db 50 dup('$')
buffer2 db 50 dup('$')
password db 50 dup('$')
user db 50 dup('$')
puntajemax db 5 dup ('$')
handle dw ?
sess db ?
cantidadusuario db 2 dup('$')
tiempo db 6 dup('0')
puntosi db 6 dup('0')
maximoi db 6 dup ('0')
useri db 16 dup ('$')
puntos dw 0
boca db ?
tipocomida db '9'
dolar db '$'
graficottiempo db "T I E M P O $  $"
graficotusuario db "U S U A R I O $"
graficotpunteo db "P U N T E O _ $ $"
graficotmaximo db "M A X I M O $ $"
.code;---------------------------------------------------------------------------------inicio segmento de codigo
mov ax, @data
mov ds, ax
jmp inicio
jmp juego
leerteclado:
call limpiarbuffer
mov si , 0
ingresar:
mov ah , 01h
int 21h
mov buffer[si],al
inc si
cmp al ,0dh
jne ingresar
ret

limpiarbuffer:
mov si,0
lmpbf1:
mov buffer[si],'$'
inc si
cmp si,50
jne lmpbf1
ret

comprobarusuario:
mov ah , 3fh
mov bx, handle
mov cx , 2
mov dx , offset cantidadusuario
int 21h 
jc erroriniciandosesion;error de lectura
mov si , 0
mov ah , cantidadusuario[0]
mov al , 10
mul al 
mov si , dx
mov al , cantidadusuario[1]
mov ah , 0
add si , ax
ciclousuario:

mov ah , 3fh
mov bx, handle
mov cx , 34
mov dx , offset buffer
int 21h 
dec si 
mov bx , 0
ciclocomparar:
mov al , buffer[bx]
mov ah , user[bx]
inc bx
cmp al , ah 
jne incorrecto
cmp bx , 21
jne ciclocomparar
ciclocompararpass:
inc bx
mov al , buffer[bx]
mov ah , password[bx-22]
cmp al , ah
jne incorrectocontra
cmp bx, 26
jne ciclocompararpass
inc bx 
inc bx ;-----------------------------------si se jode algo fijo fue esto ATENCION ATENCION 
mov al , buffer[bx]
mov puntajemax[0],al
inc bx 
mov al , buffer[bx]
mov puntajemax[1],al
inc bx 
mov al , buffer[bx]
mov puntajemax[2],al
inc bx 
mov al , buffer[bx]
mov puntajemax[3],al
inc bx 
mov al , buffer[bx]
mov puntajemax[4],al
inc bx 
jmp sesioniniciada
incorrecto:
cmp si, 0
jne ciclousuario
erroriniciandosesion:
mov dx , offset textonoexiste
mov ah , 09h 
int 21h
mov bl , 0
mov sess , bl 
ret
incorrectocontra:
mov dx , offset textonoexistecontra
mov ah , 09h 
int 21h
mov bl , 0
mov sess , bl 
ret
sesioniniciada:

mov bl , 1
mov sess , bl 
ret


abrirarchivo:
mov ah , 3dh ; abrir el fichero 
mov al , 00000010b ; los ultimos 3 ceros son los permisos
mov dx , offset archivousuario
int 21h 
jc errorarchivo
mov handle , ax
ret

cerrararchivo:
mov ah , 3eh
mov bx, handle ;movemos el manejador del archivo
int 21h 
jc errorcerrararchivo
ret


errorarchivo:
mov dx , offset textoerrorarchivo
mov ah ,09h
int 21h
jmp salir

errorcerrararchivo:
mov dx , offset textoerrorarchivocerrar
mov ah ,09h
int 21h
jmp salir
errorleerarchivo:
mov dx , offset textoerrorarchivoleer
mov ah ,09h
int 21h
jmp salir
errorescribirarchivo:
mov dx , offset textoerrorarchivoescribir
mov ah ,09h
int 21h
jmp salir

;----------------------------------------------incrementar tiempo
incrementartiempo:
mov al , tiempo[4]
cmp al , '9'
je it1
inc tiempo[4]
ret
it1: 
mov al, 48
mov tiempo[4],al
mov al , tiempo[2]
cmp al , '9'
je it2
inc tiempo[2]
ret
it2:
mov al , 48
mov tiempo[2] , al
inc tiempo[0]
ret
;----------------------------------------------incrementar puntos

incrementarpuntos:
mov dx , puntos
cmp dx , 00
je ip3
mov si , 0
ip0:
mov al , puntosi[4]
cmp al , '9'
je ip1
inc puntosi[4]
jmp ip3
ip1: 
mov al, 48
mov puntosi[4],al
mov al , puntosi[2]
cmp al , '9'
je ip2
inc puntosi[2]
jmp ip3
ip2:
mov al , 48
mov puntosi[2] , al
inc puntosi[0]
ip3:
inc si 
cmp si , puntos
jl ip0
mov dx , 00
mov puntos , dx
ret
;----------------------------------pintar incremento puntos
pintarincrementopuntos:
call incrementarpuntos
push ds
pop es
mov bp , offset tiempo
mov al , 02h
mov ah, 13h
xor bh, bh
mov bl , 2
mov cx , 3
mov dh , 5;filas
mov dl , 32;columnas
int 10h

ret
;----------------------------------------------------delay

delay:
mov si , 0ffffh
dlay1:
mov bx  , 02h
dlay:
dec bx 
cmp bx , 00
jne dlay
dec si 
cmp si , 00
jne dlay1
ret

delay2:
mov si , 000ffh
dlay12:
mov bx  , 0fh
dlay2:
dec bx 
cmp bx , 00
jne dlay2
dec si 
cmp si , 00
jne dlay12
ret


;-----------------------------------------------------pintar muro
pintarmuro:
mov dx , 55
mov di , x ;posicion inicial 
mov si , 0
lblj:
mov ax , 0
lblj1:
mov [di] , dx
inc di 
inc ax
cmp ax ,10 
jne lblj1
mov cx , 310
add di , cx
inc si 
cmp si , 10
jne lblj
ret

pintarmuro2:
mov cx , inicialx
mov dx , inicialy
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 10
k :
mov dx , inicialy
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 10
kk:
mov ah , 0ch
mov al , 55
int 10h
inc bx
inc dx 
cmp bx , 20
jne kk
inc si
inc cx
cmp si , 20
jne k
ret 

pintarvacio:
mov cx , inicialx
mov dx , inicialy
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 10
kvacio :
mov dx , inicialy
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 10
kkvacio:
mov ah , 0ch
mov al , 0
int 10h
inc bx
inc dx 
cmp bx , 20
jne kkvacio
inc si
inc cx
cmp si , 20
jne kvacio
ret 

pintarpunto:
mov cx , inicialx
mov dx , inicialy
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 14
kpunto :
mov dx , inicialy
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 14
kkpunto:
add cx , 3
add dx , 3
mov ah , 0ch
mov al , 15
int 10h
sub cx , 3
sub dx , 3
inc bx
inc dx 
cmp bx , 18
jne kkpunto
inc si
inc cx
cmp si , 18
jne kpunto
ret 

pintarcereza:
mov cx , inicialx
mov dx , inicialy
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 14
kcereza :
mov dx , inicialy
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 14
kkcereza:
add cx , 3
add dx , 3
mov ah , 0ch
mov al , 40
int 10h
sub cx , 3
sub dx , 3
inc bx
inc dx 
cmp bx , 18
jne kkcereza
inc si
inc cx
cmp si , 18
jne kcereza
ret 

pintarfresa:
mov cx , inicialx
mov dx , inicialy
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 14
kfresa :
mov dx , inicialy
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 14
kkfresa:
add cx , 3
add dx , 3
mov ah , 0ch
mov al , 36
int 10h
sub cx , 3
sub dx , 3
inc bx
inc dx 
cmp bx , 18
jne kkfresa
inc si
inc cx
cmp si , 18
jne kfresa
ret 


pintarnaranja:
mov cx , inicialx
mov dx , inicialy
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 14
knaranja :
mov dx , inicialy
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 14
kknaranja:
add cx , 3
add dx , 3
mov ah , 0ch
mov al , 42
int 10h
sub cx , 3
sub dx , 3
inc bx
inc dx 
cmp bx , 18
jne kknaranja
inc si
inc cx
cmp si , 18
jne knaranja
ret 



pintarpacman:

mov cx , posicionx
mov dx , posiciony
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 11
kpacman :
mov dx , posiciony
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 11
kkpacman:
add dx ,2
inc bx 
mov ah , 0ch
mov al , 44
int 10h
sub dx ,2 
dec bx 
inc bx
inc dx 
cmp bx , 18
jne kkpacman
inc si
inc cx
cmp si , 18
jne kpacman
ret 



;----------------------------------------------piintar matriz


pintarmatriz:
mov i , 00
mov j , 00
mov tmp , 0
lpm1:
mov j , 0
lpm2:
mov bx , tmp 
mov al , matriz[bx]  
cmp al , 48
jne pm2
mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax
call pintarmuro2
jmp pmf
pm2:

mov bx , tmp 
mov al , matriz[bx]
cmp al , 53
jne pm3
mov ah,0
mov al , j
mov posicionx ,ax
mov al , i
mov posiciony,ax
call pintarpacman1

jmp pmf 
pm3:
mov bx , tmp
mov al , matriz[bx]
cmp al ,50
jne pm4
mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax

call pintarpunto

jmp pmf 
pm4:
mov bx , tmp
mov al , matriz[bx]
cmp al ,49
jne pm5
mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax

call pintarcereza

jmp pmf 
pm5:
mov bx , tmp
mov al , matriz[bx]
cmp al ,51
jne pm6
mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax
call pintarfresa
jmp pmf 
pm6:
mov bx , tmp
mov al , matriz[bx]
cmp al ,52
jne pm7
mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax
call pintarnaranja
jmp pmf 
pm7:
mov bx , tmp
mov al , matriz[bx]
cmp al ,99
jne pm8
mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax
call pintarmuro2
jmp pmf 
pm8:

mov ah,0
mov al , j
mov inicialx,ax
mov al , i
mov inicialy,ax

call pintarvacio
pmf:
inc tmp
inc j 
cmp j , 25
jne lpm21
inc i 
cmp i , 20
jne lpm11
ret 
lpm11:
jmp lpm1 
lpm21:
jmp lpm2

;---------------------------------control de comida
comida:
cmp tipocomida , 50
jne cc1
mov cx , 1
jmp ccf
cc1:
cmp tipocomida , 49
jne cc2
mov cx , 25
jmp ccf 
cc2:
cmp tipocomida , 51
jne cc3
mov cx , 15
jmp ccf 
cc3:
cmp tipocomida , 52
jne ccf4
mov cx , 5
jmp ccf 
ccf4:
mov cx , 0

ccf:
mov puntos ,cx
mov al , 59
mov tipocomida , al
ret


;-----------------------------------------------------setear mapa
setmuros:
mov al , 48
mov bx , 0
mov cx , 0
sm1:
mov matriz[bx], al
add bx , 25
inc cx 
cmp cx , 20
jne sm1
mov al , '9'
mov matriz[225] , al
mov al , 48
mov cx , 00
mov bx , 24
sm2:
mov matriz[bx], al
add bx , 25
inc cx 
cmp cx , 20
jne sm2
mov al , '9'
mov matriz[249] , al 
mov al , 48
mov cx , 00
mov bx , 0
sm3:
mov matriz[bx],al
inc bx 
cmp bx , 25
jne sm3
mov al , '9'
mov matriz[12],al

mov al , 48
mov cx , 00
mov bx , 475
sm4:
mov matriz[bx],al
inc bx 
cmp bx , 500
jne sm4
mov al , '9'
mov matriz[487],al

ret




salir:
mov ax,4c00h
int 21h
;------------------------------------------------------------------------------------------------------inicio programa
inicio:
mov dx, offset textomenu
mov ah, 9
int 21h

mov ah,01h;leemos tecla
int 21h
mov dx , offset textoingresar
mov ah, 9
cmp al , 51
je salir
cmp al, 50
je registrar
int 21h

call leerteclado
mov si , 0
copiarusuario:
mov dl , buffer[si]
mov user[si],dl
inc si
cmp si , 50d
jne copiarusuario
call limpiarbuffer
call leerteclado
mov si , 0
copiarpassword:
mov dl , buffer[si]
mov password[si],dl
inc si
cmp si , 50d
jne copiarpassword
call limpiarbuffer

call abrirarchivo
call comprobarusuario
call cerrararchivo
;-------------------------------------aca ya se inicio sesion
cmp sess , 1
je sesion  
jmp inicio
sesion:
mov dx , offset textomenujuego
mov ah , 09
int 21h 
mov ah,01h;leemos tecla
int 21h
cmp al , 49 ;iniciar juego
je inijuego
cmp al , 50 ;volver al juego
je voljuego
cmp al , 51 ; limpiar juego
je limjuego
cmp al , 52 ; logout 
je llogout
jmp sesion
inijuego:
jmp juego
voljuego:
mov ax , 0013h
int 10h
jmp regresaraljuego
limjuego:
call setmapacaquero
call frutasrandomicas

jmp sesion
llogout:
call comprobaryguardarpuntaje
jmp inicio

registrar:;-----------------------------------------------------------------------------inicio registro de usuario
mov dx , offset textoregistro
mov ah, 9
int 21h

call leerteclado
mov si , 0
copiarusuario1:
mov dl , buffer[si]
mov user[si],dl
inc si
cmp si , 50d
jne copiarusuario1
call limpiarbuffer
call leerteclado
mov al , buffer[5]
cmp al , 0dh
je requisitocontra
call limpiarbuffer
mov dx , offset textorequisitocontra
mov ah , 09 
int 21h
jmp inicio
requisitocontra:
mov si , 0
copiarpassword1:
mov dl , buffer[si]
mov password[si],dl
inc si
cmp si , 50d
jne copiarpassword1
call limpiarbuffer
call leerteclado
mov si , 0
compararpasswords:
mov al , buffer[si]
mov ah , password[si]
cmp al , ah
jne segundacontrasenamala
inc si
cmp si , 50
jne compararpasswords
jmp iniciarregistrousuario
segundacontrasenamala:
mov dx , offset textoingresoincorrecto
mov ah , 09h
int 21h 
jmp inicio

;-------------------------------------------------------------------------------------iniciar el registro en el archivo
iniciarregistrousuario:
call abrirarchivo

comprobarusuario1:
mov ah , 3fh
mov bx, handle
mov cx , 2
mov dx , offset cantidadusuario
int 21h 


mov si , 0
mov ah , cantidadusuario[0]
mov al , 10
mul al 
mov si , dx
mov al , cantidadusuario[1]
mov ah , 0
add si , ax
ciclousuario1:
mov ah , 3fh
mov bx, handle
mov cx , 34
mov dx , offset buffer
int 21h 
dec si 
mov bx , 0
ciclocomparar1:
mov al , buffer[bx]
mov ah , user[bx]
inc bx
cmp al , ah 
jne incorrecto1
cmp bx , 21
jne ciclocomparar1
inc bx
mov dx, offset textousuarioexiste
mov ah , 09h
int 21h
jmp inicio
incorrecto1:
cmp si, 0
jne ciclousuario1
call limpiarbuffer

mov si , 0
lb1:
mov al , user[si]
mov buffer[si], al
inc si
cmp si , 21
jne lb1
mov al , ';'
mov buffer[si], al
mov si, 0
lb2:
mov al , password[si]
mov buffer[si+22] , al
inc si 
cmp si,6
jne lb2
mov buffer[27],';'
mov buffer[28], 48
mov buffer[29], 48
mov buffer[30], 48
mov buffer[31], 48
mov buffer[32], 48
mov buffer[33], '$'


mov ah , 40h
mov bx , handle
mov cx , 34
mov dx , offset buffer
int 21h 

mov ah ,42h;-----------------------puntero del archivo 
mov al ,00
mov bx , handle
mov cx , 00
mov dx , 00
int 21h
add cantidadusuario[1] , 1
mov ah , 40h
mov bx , handle
mov cx , 2
mov dx , offset cantidadusuario
int 21h 
call cerrararchivo
mov dx , offset textousuariocreado
mov ah , 09h
int 21h
jmp salir

ret
sesioniniciada1:
ret
















;lectura archivo
mov ah , 3fh
mov bx, handle
mov cx , 49
mov dx , offset buffer
int 21h 
;jc errorleerarchivo
mov ah , 09h
int 21h


call limpiarbuffer
call leerteclado

;escribir en el archivo
mov ah , 40h
mov bx , handle
mov cx , 50
mov dx , offset buffer
int 21h 
;jc errorescribirarchivo



;cerramos el archivo 


juego:



mov ax , 0013h
int 10h


 

call setmapacaquero
call frutasrandomicas
mov al , 53
mov bx , 26
mov pospacman , bx 
mov matriz[bx],al
mov direccionpacman , 'd'

regresaraljuego:
mov al , user[0]
mov useri[0] , al 
mov al , user[1]
mov useri[2] , al 
mov al , user[2]
mov useri[4] , al 
mov al , user[3]
mov useri[6] , al 
mov al , user[4]
mov useri[8] , al 
mov al , user[5]
mov useri[10] , al 
mov al , user[6]
mov useri[12] , al 
mov al , user[7]
mov useri[14] , al 


mov al , puntajemax[2]
mov maximoi[0],al
mov al , puntajemax[3]
mov maximoi[2],al
mov al , puntajemax[4]
mov maximoi[4],al

push ds
pop es

mov bp , offset graficotusuario
mov al , 02h
mov ah, 13h
xor bh, bh
mov bl , 2
mov cx , 8
mov dh ,1;filas
mov dl , 32;columnas
int 10h
mov bp , offset graficottiempo
mov dh , 4;filas
int 10h
mov bp , offset graficotpunteo
mov dh , 6;filas
int 10h

mov bp , offset graficotmaximo
mov dh , 9;filas
int 10h



mov bp , offset useri
mov dh , 2;filas
int 10h
mov cx , 3
mov bp , offset maximoi
mov dh , 10;filas
int 10h

escuchar:
call pintarmatriz

cmp direccionpacman, 'd'
jne esc1
mov bx, pospacman
mov al , matriz[bx+1]
mov tipocomida , al
cmp al , 48
je escfb 
mov matriz[bx],'9'
inc bx 
mov matriz[bx],53
inc pospacman
jmp escf
escfb:
jmp escf
esc1:
cmp direccionpacman, 'a'
jne esc2
mov bx, pospacman
dec bx 
mov al , matriz[bx]
mov tipocomida , al
cmp al , 48
je escf
 mov bx , pospacman
mov matriz[bx],'9'
dec bx 
mov matriz[bx],53
dec pospacman
jmp escf
esc2:
cmp direccionpacman, 's'
jne esc3
mov bx, pospacman 
mov al , matriz[bx+25]
mov tipocomida , al
cmp al , 48
je escf 
mov bx , pospacman
mov matriz[bx],'9'
add bx , 25
mov matriz[bx],53
mov pospacman , bx
jmp escf
esc3:
cmp direccionpacman, 'w'
jne escf
mov bx, pospacman
mov al , matriz[bx-25]
mov tipocomida , al
cmp al , 48
je escf 
mov bx , pospacman
mov matriz[bx],'9'
sub bx , 25 
mov matriz[bx],53
mov pospacman, bx
jmp escf


escf:
cmp bx , 224
je escfff
jmp escfff1
escfff:
mov bx , 249
mov al , 99
mov matriz[224] ,al 
mov matriz[250] ,al
mov matriz[bx], 53
mov pospacman  , bx 
jmp escffs
escfff1:
cmp bx , 250
je escfff12
jmp escffs
escfff12:
mov bx , 225
mov al , 99
mov matriz[224] ,al 
mov matriz[250] ,al
mov matriz[bx], 53
mov pospacman , bx 
escffs:

call delay
mov ah , 06h
mov dl , 0ffh
int 21h 
jz esini
mov direccionpacman , al
cmp al , 'm'
je finescucha 
esini:

mov ah , 2ch
int 21h ;-------------------------para contar los segundos
cmp segundoactual , dh 
je seg1 
mov segundoactual , dh
call incrementartiempo
seg1:
push ds
pop es
mov bp , offset tiempo
mov al , 02h
mov ah, 13h
xor bh, bh
mov bl , 2
mov cx , 3
mov dh , 5;filas
mov dl , 32;columnas
int 10h




mov dh , 7
mov bp , offset puntosi
int 10h
call comida
call pintarincrementopuntos
jmp escuchar

finescucha:
mov ax , 0003h
int 10h

jmp sesion

mov ah , 10h;esperar por tecla
int 16h




mov ah ,09h
mov dx , offset puntosi
int 21h





jmp salir


frutasrandomicas:
mov bx , 00
fr1:
mov al , matriz[bx]
cmp al , '9'
jne frf
mov ah , 2ch 
int 21h 
mov dh , 00
mov ax , dx 
mov dh , 10
div dh 
mov dl , ah 

cmp dl ,2
jg frc1
mov al , 50
jmp  frcf9
frc1:
cmp dl ,5
jg frc2
mov al , 52
jmp  frcf9
frc2:
cmp dl ,7
jg frc3
mov al , 51
jmp  frcf9
frc3:
cmp dl ,10
jg frc4
mov al , 49
frcf9:
mov matriz[bx],al 
call delay2
frc4:
frf:
inc bx 
cmp bx , 500
jne fr1
ret


comprobaryguardarpuntaje:
mov al , puntajemax[2]
mov ah , puntosi[0]
cmp al , ah 
jg fcgyp
cmp ah , al 
je cgyp1
jmp fcgypM
cgyp1:
mov al , puntajemax[3]
mov ah , puntosi[2]
cmp al , ah 
jg fcgyp
cmp ah , al 
je cgyp2
jmp fcgypM
cgyp2:
mov al , puntajemax[4]
mov ah , puntosi[4]
cmp al , ah 
jg fcgyp
cmp ah , al 
je fcgyp
jmp fcgypM
fcgyp:;punteo anterior es mayor
 mov dx , offset puntajemax
 mov ah , 09
 int 21h 
ret


fcgypM:;punteo nuevo es mayor
mov al , 48
mov puntajemax[0], al 
mov puntajemax[1],al

mov al , puntosi[0]
mov puntajemax[2],al 
mov al , puntosi[2]
mov puntajemax[3],al
mov al , puntosi[4]
mov puntajemax[4],al 

mov al  , 00
mov usuarioactual,al
call abrirarchivo
mov ah ,42h
mov al ,00
mov bx , handle
mov cx , 00
mov dx , 2
int 21h


cualeselusuario: 
mov ah , 3fh
mov bx, handle
mov cx , 34
mov dx , offset buffer
int 21h
mov al , buffer[0]
mov ah , user[0]
cmp al , ah 
jne cualeselusuario1
mov al , buffer[1]
mov ah , user[1]
cmp al , ah 
jne cualeselusuario1
mov al , buffer[4]
mov ah , user[4]
cmp al , ah 
jne cualeselusuario1
jmp cualeselusuariofin
 
cualeselusuario1:
inc usuarioactual
jmp cualeselusuario

cualeselusuariofin:
 
mov ah , usuarioactual
mov al , 34
mul ah 
add ax , 30
mov dx , ax 

mov ah ,42h
mov al ,00
mov bx , handle
mov cx , 00
int 21h
mov ah , 40h
mov bx , handle
mov cx , 5
mov dx , offset puntajemax
int 21h 


call cerrararchivo
mov dx , offset puntajemax
mov ah , 09 
int 21h 

ret





setmapacaquero:
mov al , 48
mov matriz[0] , al
mov matriz[1] , al
mov matriz[2] , al
mov matriz[3] , al
mov matriz[4] , al
mov matriz[5] , al
mov matriz[6] , al
mov matriz[7] , al
mov matriz[8] , al
mov matriz[9] , al
mov matriz[10] , al
mov matriz[11] , al
mov matriz[12] , al
mov matriz[13] , al
mov matriz[14] , al
mov matriz[15] , al
mov matriz[16] , al
mov matriz[17] , al
mov matriz[18] , al
mov matriz[19] , al
mov matriz[20] , al
mov matriz[21] , al
mov matriz[22] , al
mov matriz[23] , al
mov matriz[24] , al
mov matriz[25] , al
mov matriz[49] , al
mov matriz[50] , al
mov matriz[52] , al
mov matriz[53] , al
mov matriz[54] , al
mov matriz[55] , al
mov matriz[56] , al
mov matriz[57] , al
mov matriz[58] , al
mov matriz[59] , al
mov matriz[60] , al
mov matriz[62] , al
mov matriz[64] , al
mov matriz[65] , al
mov matriz[66] , al
mov matriz[67] , al
mov matriz[68] , al
mov matriz[69] , al
mov matriz[70] , al
mov matriz[71] , al
mov matriz[72] , al
mov matriz[74] , al
mov matriz[75] , al
mov matriz[87] , al
mov matriz[99] , al
mov matriz[100] , al
mov matriz[124] , al
mov matriz[125] , al
mov matriz[126] , al
mov matriz[127] , al
mov matriz[128] , al
mov matriz[129] , al
mov matriz[137] , al
mov matriz[145] , al
mov matriz[146] , al
mov matriz[147] , al
mov matriz[148] , al
mov matriz[149] , al
mov matriz[154] , al
mov matriz[157] , al
mov matriz[160] , al
mov matriz[161] , al
mov matriz[162] , al
mov matriz[163] , al
mov matriz[164] , al
mov matriz[167] , al
mov matriz[170] , al
mov matriz[179] , al
mov matriz[182] , al
mov matriz[192] , al
mov matriz[195] , al
mov matriz[200] , al
mov matriz[201] , al
mov matriz[202] , al
mov matriz[203] , al
mov matriz[204] , al
mov matriz[207] , al
mov matriz[210] , al
mov matriz[211] , al
mov matriz[213] , al
mov matriz[214] , al
mov matriz[217] , al
mov matriz[220] , al
mov matriz[221] , al
mov matriz[222] , al
mov matriz[223] , al
mov matriz[224] , al
mov matriz[235] , al
mov matriz[239] , al
mov matriz[250] , al
mov matriz[251] , al
mov matriz[252] , al
mov matriz[253] , al
mov matriz[254] , al
mov matriz[257] , al
mov matriz[260] , al
mov matriz[264] , al
mov matriz[267] , al
mov matriz[270] , al
mov matriz[271] , al
mov matriz[272] , al
mov matriz[273] , al
mov matriz[274] , al
mov matriz[279] , al
mov matriz[282] , al
mov matriz[285] , al
mov matriz[286] , al
mov matriz[287] , al
mov matriz[288] , al
mov matriz[289] , al
mov matriz[292] , al
mov matriz[295] , al
mov matriz[304] , al
mov matriz[307] , al
mov matriz[317] , al
mov matriz[320] , al
mov matriz[325] , al
mov matriz[326] , al
mov matriz[327] , al
mov matriz[328] , al
mov matriz[329] , al
mov matriz[335] , al
mov matriz[336] , al
mov matriz[337] , al
mov matriz[338] , al
mov matriz[339] , al
mov matriz[345] , al
mov matriz[346] , al
mov matriz[347] , al
mov matriz[348] , al
mov matriz[349] , al
mov matriz[350] , al
mov matriz[362] , al
mov matriz[374] , al
mov matriz[375] , al
mov matriz[382] , al
mov matriz[392] , al
mov matriz[399] , al
mov matriz[400] , al
mov matriz[407] , al
mov matriz[412] , al
mov matriz[417] , al
mov matriz[424] , al
mov matriz[425] , al
mov matriz[428] , al
mov matriz[429] , al
mov matriz[430] , al
mov matriz[431] , al
mov matriz[432] , al
mov matriz[433] , al
mov matriz[434] , al
mov matriz[437] , al
mov matriz[440] , al
mov matriz[441] , al
mov matriz[442] , al
mov matriz[443] , al
mov matriz[444] , al
mov matriz[445] , al
mov matriz[446] , al
mov matriz[449] , al
mov matriz[450] , al
mov matriz[462] , al
mov matriz[474] , al
mov matriz[475] , al
mov matriz[476] , al
mov matriz[477] , al
mov matriz[478] , al
mov matriz[479] , al
mov matriz[480] , al
mov matriz[481] , al
mov matriz[482] , al
mov matriz[483] , al
mov matriz[484] , al
mov matriz[485] , al
mov matriz[486] , al
mov matriz[487] , al
mov matriz[488] , al
mov matriz[489] , al
mov matriz[490] , al
mov matriz[491] , al
mov matriz[492] , al
mov matriz[493] , al
mov matriz[494] , al
mov matriz[495] , al
mov matriz[496] , al
mov matriz[497] , al
mov matriz[498] , al
mov matriz[499] , al

mov al , 99
mov matriz[224],al
mov matriz[250], al 
mov al , 77
mov matriz[150], al 
mov matriz[151], al 
mov matriz[152], al 
mov matriz[153], al 

mov matriz[171], al 
mov matriz[172], al 
mov matriz[173], al 
mov matriz[174], al 

mov matriz[175], al 
mov matriz[176], al 
mov matriz[177], al 
mov matriz[178], al 

mov matriz[196], al 
mov matriz[197], al 
mov matriz[198], al 
mov matriz[199], al
 
mov matriz[275], al 
mov matriz[276], al 
mov matriz[277], al 
mov matriz[278], al 

mov matriz[296], al 
mov matriz[297], al 
mov matriz[298], al 
mov matriz[299], al 

mov matriz[300], al 
mov matriz[301], al 
mov matriz[302], al 
mov matriz[303], al 

mov matriz[321], al 
mov matriz[322], al 
mov matriz[323], al 
mov matriz[324], al 
mov bx , pospacman
mov al , '9'
mov matriz[bx], al 
mov bx , 26
mov pospacman , bx 
mov matriz[bx],al
mov direccionpacman , 'd'
mov al  , 48

mov puntosi[0],al
mov puntosi[2],al
mov puntosi[4],al
mov tiempo[0],al
mov tiempo[2],al
mov tiempo[4],al

mov al , 48
mov matriz[0] , al
ret 


pintarpacman1:
cmp boca , 00
je pacmanbocacerrada
jmp pacmanbocaabierta
pacmanbocacerrada:
mov cx , posicionx
mov dx , posiciony
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 10
kpacman1 :
mov dx , posiciony
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 10
kkpacman1:
mov ah , 0ch
mov al , 44

mov si , dx
;pintamos primer fila 
add dx , 4
int 10h
add dx , 1
int 10h

mov dx , si 
inc cx 

add dx , 2
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si 
inc cx 

add dx , 2
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si 
inc cx 

add dx , 1
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si 
inc cx 

add dx , 1
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
mov dx , si 
inc cx 

add dx , 2
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

add dx , 4
int 10h
add dx , 1
int 10h

mov dx , si 
inc cx 

add dx , 2
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
mov dx , si 
inc cx 
add dx , 4
int 10h
add dx , 1
int 10h
mov al , 1
mov boca,al
ret 

pacmanbocaabierta:

mov cx , posicionx
mov dx , posiciony
mov al , cl
mov ah , 10
mul ah
mov cx , ax 
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov si , 10
mov dx , posiciony
mov al , dl 
mov ah , 10
mul ah
mov dx , ax
mov bx , 10
mov ah , 0ch
mov al , 44

mov si , dx
;pintamos primer fila 
add dx , 4
int 10h
add dx , 1
int 10h

mov dx , si 
inc cx 

add dx , 2
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si 
inc cx 

add dx , 2
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si 
inc cx 

add dx , 1
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h



mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx
inc dx 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx 
int 10h
inc dx
inc dx 
inc dx 
inc dx 
inc dx 
int 10h
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h 
inc dx 
int 10h
inc dx
inc dx 
inc dx 
inc dx 
inc dx 
inc dx 
inc dx 
int 10h
inc dx 
int 10h

mov dx , si
inc cx
int 10h
inc dx
inc dx 
inc dx 
inc dx 
inc dx 
inc dx 
inc dx 
inc dx 
inc dx 
int 10h
mov al , 0
mov boca,al
ret



mov al , 50
mov matriz[55] ,al
mov matriz[448],al
mov matriz[330],al
mov al , 49
mov matriz[72] ,al
mov matriz[222],al
mov matriz[427],al
mov al , 51
mov matriz[110] ,al
mov matriz[368],al
mov matriz[457],al
mov al , 52
mov matriz[134] ,al
mov matriz[268],al
mov matriz[367],al




end



