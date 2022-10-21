# TerraformCloud

Trabajo practico 3 para la materia Cloud Computing 2022

## Módulos

Para la generación de la infraestructura utilizando terraform se estructuró la configuración utilizando múltiples módulos donde se agrupan configuraciones relacionadas de forma tal de simplificar el manejo y de evitar la repetición. Estos módulos son combinados en un main principal el cual es configurable vía variables.

### Módulo Certificate
    
Pequeño módulo que agrupa las configuraciones necesarias para la generación de un certificado TLS. Esto consiste en solicitar el certificado, generar los registros apropiados en route53 y esperar que se valide exitosamente.

### Módulo DNS
    
Este módulo se encarga de generar los registros de DNS apropiados para exponer el CDN.

### Módulo CDN

Este módulo define la configuración de Cloudfront. Esto implica definir los distintos orígenes de la información (static-site y API Gateway) así como las políticas para rutear el tráfico y cachear el contenido.

### Modulo S3
    
Módulo utilizado del registry. Este permite generar buckets de S3 con total flexibilidad.

### Módulo Website
    
Configuración del sitio estático. Dentro de este proceso se encuentra la definición de los buckets, subida de archivos y configuración para que el bucket sea un sitio estático. Para la definición de los buckets se hizo uso del módulo de S3 ya mencionado. Estos buckets son privados y son solo accesibles por el CDN. Para esto el módulo recibe el origin access identity que será utilizado por el CDN. Respecto a la subida de los archivos, el módulo recibe un path dentro del proyecto. Este lo usará para recorrer todos los archivos y subirlo a S3 con su correspondiente MIME.

### Módulo VPC

Se construye el módulo subnet que permite definir la VPC en la cual se trabajará. Este módulo se ocupará también de la generación de subnets y las tablas de ruteo. Para que el módulo sea reutilizable y pueda recibir la cantidad de subnets que se desean generar se utilizará la siguiente funcionalidad: cidrsubnet(local.private_cidr, ceil(log(var.zones_count, 2)), count.index)
Esta función hará dependiente los cidr a utilizar de las subnets, de la cantidad de subnets recibidas a la hora de generar el módulo. Las variables expuestas en el output serán el id, el cidr de la vpc y todas los ids de las private subnets, recorriendo las con un for.
Por último, en este módulo se define también el internet gateway.

### Módulo Lambda
    
Se definió una arquitectura serverless donde la lógica será implementada mediante funciones lambda. El módulo lambda será de vital importancia para definir las diferentes implementaciones a usar en el trabajo. Debido a que este módulo será altamente configurable, el mismo recibirá una gran cantidad de variables. Estas cuentan con sus descripciones en el archivo variables.tf. Cabe destacar que se reciben tanto variables necesarias para la definición de la función, como otras que se utilizarán una vez ésta ya haya sido definida. Entre estas, por ejemplo, las necesarias para definir una entrada REST para el API gateway. Se definió de esta manera para evitar complejizar de dicho módulo con cosas propias de la función. Para la generación de las lambdas se define la policy correspondiente, la cual deberá permitir la creación de las mismas dentro de una VPC.

### Módulo API Gateway

Se utilizará a las funciones lambda como endpoints REST. Para poder acceder a ellos se define un api gateway. Se debe de analizar si los endpoints han cambiado para redeployear la configuración del api. Para esto, se recibe una lista con los hashes de todos los endpoints que se presentarán en el api gateway para chequear si han habido cambios.

## Elementos

Los elementos definidos son

- **Route53:** Implementado en los módulos dns y certificate.
- **S3:** Implementado en módulo externo y utilizado en el static site.
- **Cloudfront:** Implementado en cdn.
- **VPC:** Implementado en vpc.
- **Lambda:** Implementado en lambda.
- **API Gateway:** Implementado en api_gateway.

También se implementó: Certificate Manager, Dynamo, IAM.

## Funciones

Se hizo uso de las siguientes funciones provistas por terraform.

- **cidrsubnet:** esta función nos permite particionar el CIDR asignado a la VPC de forma programática en función de la cantidad de subredes a utilizar. En: `vpc/locals.tf`
- **fileset:** esta función permite recorrer el directorio provisto con los archivos del sitio estático y levantar todos los archivos asociados a una extensión. En: `static_site/locals.tf`
- **flatten:** esta función nos permite unificar una lista de listas en una única lista. En: `static_site/locals.tf`
- **ceil y log:** se utilizan estas funciones matemáticas para calcular la cantidad de bits a utilizar a la hora de particionar el CIDR. En: `vpc/main.tf`

## Meta Argumentos

Se hizo uso de los siguientes meta argumentos.

- **count:** Se utilizó este argumento para la generación de las subredes privadas de forma dinámica. En: `vpc/main.tf`
- **for_each:** Se utilizó este argumento para la subida de los archivos. Permite iterar la lista con todos los archivos y subirlos de a uno. En: `static_site/upload.tf`
- **depends_on:** Se utilizó este argumento para el manejo de dependencias en la configuración de las funciones lambdas y su mapeo en el API Gateway. En: `lambda/main.tf`
