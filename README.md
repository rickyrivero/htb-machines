
# HTB-machines

La funcionalidad de este script es hacer una petición a la web de un creador de contenido español (**@s4vitar**) de hacking, quien se dedica a resolver máquinas en HackTheBox para luego dejar un pequeño resumen en esta página acerca de las skills que se tocan en x máquina, que sistema operativo tiene, entre otros filros. La página en cuestión es (https://htbmachines.github.io/)

El objetivo es hacer las consultas de las máquinas de manera local esto se logra ya que usando el comando **-u** el script hace una petición al archivo .js que almacena toda la información de las máquinas en la web, una vez realizado se crea una copia del archivo .js en local del cual se buscará extraer la información necesaria con los otros comandos selecionados

## Opciones:
```
[+] Uso:
	u) Descargar o actualizar archivos necesarios
	m) Buscar por un nombre de máquina
	i) Buscar por dirección IP
	d) Buscar por nivel de dificultad
	o) Buscar por el sistema operativo
	s) Buscar por tipo de skill
	c) Buscar por tipo de certificación
	y) Obtener link de youtube
	h) Mostrar panel de ayuda

[+] Combinar:
	d+o) Búsqueda combinada de dificultad y sistema operativo
```
## Uso:

En la mayoría de los inputs no hará falta el uso de comillas, pero si el valor que se busca ingresar tiene más de 1 palabra si se tendrá que usar las comillas para que pueda funcionar adecuadamente el programa

Buscar por tipo de habilidad:
```
./htbmachines.sh -s "Active Directory"
```
Operación combinada:
```
./htbmachines.sh -d Insane -o Linux
```

## Tecnologías usadas

- Bash
