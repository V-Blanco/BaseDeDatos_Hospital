-------------------------------------------------

--- TRABAJO PRACTICO BASES DE DATOS APLICADAS ---
--- COM. 02-5600

--- GRUPO 14:
--- BLANCO, VICTORIA - DNI 44447600 
--- D'AGOSTINO, LUCA - DNI 44318898

-------------------------------------------------
--si ya existía la base de datos, se elimina y se crea una nueva.
IF EXISTS (
    SELECT name FROM sys.databases WHERE name = 'cureSA'
)
BEGIN;
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'DROP DATABASE cureSA;';
    EXEC sp_executesql @sql;
END;
GO

CREATE DATABASE cureSA
GO

USE cureSA
GO

--crea el esquema, si no existe
IF NOT EXISTS (
    SELECT schema_id FROM sys.schemas WHERE name = 'ddbba'
)
BEGIN;
	DECLARE @sql2 NVARCHAR(MAX);
	SET @sql2 = N'CREATE SCHEMA ddbba;';
    EXEC sp_executesql @sql2;
END;
GO

-- BORRADO LOGICO --

create table ddbba.prestador(
	id_prestador int identity(1,1) primary key,
	nombre_prestador varchar(30),
	plan_prestador varchar(30),
	registro_eliminado BIT DEFAULT 0
)
GO

--las imagenes las tomamos como rutas
--tambien el documento resultado de estudio
create table ddbba.paciente(
	id_Historia_Clinica int identity(1,1) primary key,
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	apellido_materno varchar(30),
	fecha_nacimiento date,
	tipo_documento varchar(8),
	dni int check(dni>0),
	sexo_biologico varchar(10),
	genero varchar(7),
	nacionalidad varchar(30),
	foto_de_perfil varchar(200),
	mail varchar(40),
	telefono_fijo varchar(20),
	telefono_alternativo varchar(20),
	telefono_laboral varchar(20),
	fecha_de_registro date default getdate(),
	fecha_actualizacion date default null,
	usuario_actualizacion varchar(20),
	registro_eliminado BIT DEFAULT 0,
	CONSTRAINT ck_sexo_biologico CHECK (sexo_biologico IN ('Masculino','masculino', 'Femenino','femenino')),
	CONSTRAINT ck_genero CHECK (genero IN ('Hombre','hombre','mujer', 'Mujer','Trans','trans'))
)
GO

create table ddbba.sedeDeAtencion(
	id_sede int identity(1,1) primary key,
	nombre_sede varchar(40),
	direccion varchar(50),
	localidad varchar(30),
	provincia varchar(30),
	registro_eliminado BIT DEFAULT 0
)
GO

create table ddbba.especialidad(
	id_especialidad int identity(1,1) primary key,
	nombre_especialidad varchar(30),
	registro_eliminado BIT DEFAULT 0
)
GO

create table ddbba.medico(
	id_medico int identity(1,1) primary key,
	id_especialidad int foreign key references ddbba.especialidad(id_especialidad),
	nombre varchar(30),
	apellido varchar(30),
	nro_matricula int,
	registro_eliminado BIT DEFAULT 0
)
GO

create table ddbba.tipoTurno(
	id_tipo_turno int identity(1,1) primary key,
	tipo_turno varchar(30),
	registro_eliminado BIT DEFAULT 0,
	CONSTRAINT ck_tipo_turno CHECK (tipo_turno IN ('Virtual', 'Presencial'))
)
GO

create table ddbba.estadoTurno(
	id_estado int identity(1,1) primary key,
	nombre_estado varchar(30),
	registro_eliminado BIT DEFAULT 0,
	CONSTRAINT ck_nombre_estado CHECK (nombre_estado IN ('Disponible','Atendido' ,'Ausente', 'Cancelado'))
)
GO

-- BORRADO FISICO --

create table ddbba.cobertura(
	id_Cobertura int primary key foreign key references ddbba.paciente(id_Historia_Clinica),
	id_Prestador int foreign key references ddbba.prestador(id_prestador),
	imagen_credencial varchar(200),
	nro_socio int,
	fecha_registro date
)
GO

create table ddbba.usuario(
	id_Usuario int identity(1,1) primary key,
	id_paciente int foreign key references ddbba.paciente(id_Historia_Clinica),
	contraseña varchar(20),
	fecha_creacion date
)
GO

create table ddbba.domicilio(
	id_domicilio int identity(1,1) primary key,
	id_paciente int foreign key references ddbba.paciente(id_Historia_Clinica),
	calle varchar(90),
	nro varchar(20),
	piso int,
	departamento char(5),
	cod_postal char(5),
	pais varchar(30),
	provincia varchar(30),
	localidad varchar(50)
)
GO

create table ddbba.estudio(
	id_estudio int identity(1,1) primary key,
	id_paciente int foreign key references ddbba.paciente(id_Historia_Clinica),
	fecha date,
	nombre_estudio varchar(200),
	autorizado varchar(10),
	documento_resultado varchar(200),
	imagen_resultado varchar(200)
)
GO

create table ddbba.diasXSede(
	id_sede int foreign key references ddbba.sedeDeAtencion(id_sede),
	id_medico int foreign key references ddbba.medico(id_medico),
	dia varchar(15),
	hora_inicio time(0)
)
GO

create table ddbba.reservaTurnoMedico(
	id_turno int identity(1,1) primary key,
	id_paciente int foreign key references ddbba.paciente(id_Historia_Clinica),--
	fecha date,
	hora time(0),--
	id_medico int foreign key references ddbba.medico(id_medico),--
	id_especialidad int foreign key references ddbba.especialidad(id_especialidad),--
	id_direccion_atencion int foreign key references ddbba.sedeDeAtencion(id_sede),--
	id_estado_turno int foreign key references ddbba.estadoTurno(id_estado),--
	id_tipo_turno int foreign key references ddbba.tipoTurno(id_tipo_turno),--
	CONSTRAINT ck_hora CHECK (DATEDIFF(MINUTE, '00:00:00', hora) % 15 = 0) --que solo acepte hora de a 15 minutos
)

-- TABLA JSON --

create table ddbba.parametrosEstudios
(
	id_estudio varchar(40),
	area varchar(30),
	nombre_estudio varchar(100),
	nombre_prestador varchar(30),
	plan_prestador varchar(30),
	porcentaje_cobertura int,
	costo int,
	autorizacion BIT
)
GO
