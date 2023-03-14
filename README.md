# GCP-Paolo
<h2>Practica GCP Paolo Scotto Di Mase</h2>


***Project ID: premium-cipher-374400***

1.- Realizar un git clone del respositorio:  
   
     git@github.com:KeepCodingCloudDevops7/GCP-Paolo.git

2.- En la tercera parte el grupo de instancias de autoescalado tiene 3 istancias en vez de 4 por el problema que tuve con la capa gratuita que no deja
levantar mas de 4 istancias por region. Ademas no hay disponibilidad en la zona "a" por lo que usé la "b" y la "c".
En la istancia "comprobacion-autoescalado" hay el script de comprobación que calcula automaticamente la IP de la istancia principal del grupo para
mandarle trafico. Hay 2 ejemplos, uno con el comando "ab" (Apache benchmark) y otro con el comando "ping". Para ejecutarlo:    
                                   
     sudo bash traffic_script1.sh


3.- La practica incluye el bonus con la configuracion de Terraform. Puntos a destacar:
- Creación de un firewall para permitir trafico HTTP en el puerto 80.
- En la definición de la istancia se añade un script de configuracion inicial que instala apache2.
- Creación de una cuenta de servicio con determinados permisos para que pueda gestionar el bucket.




