use cureSA
go

--crea el esquema, si no existe
IF NOT EXISTS (
    SELECT schema_id FROM sys.schemas WHERE name = 'dbproc'
)
BEGIN;
	DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'CREATE SCHEMA dbproc;';
    EXEC sp_executesql @sql;
END;
GO

-- STORED PROCEDURES DE INSERCIÓN

-- Insertar Usuario
GO
CREATE PROC dbproc.insertUsuario(@id_paciente int ,@contraseñas varchar(50),@fecha_creacion date)
AS
BEGIN
	--validaciones
	IF (@id_paciente IS NULL OR @contraseñas IS NULL)
    BEGIN
        RAISERROR('Los campos id_paciente, contraseña no pueden ser nulos.', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.paciente WHERE id_Historia_Clinica = @id_paciente)
    BEGIN
        RAISERROR('El id_paciente especificado no existe en la tabla paciente.', 16, 1);
        RETURN;
    END
    IF (LEN(@contraseñas) < 8 OR LEN(@contraseñas) > 50)
    BEGIN
        RAISERROR('La contraseña debe tener entre 8 y 50 caracteres.', 16, 1);
        RETURN;
    END
    IF (@fecha_creacion > GETDATE())
    BEGIN
        RAISERROR('La fecha de creación no puede ser en el futuro.', 16, 1);
        RETURN;
    END

	--insercion
	INSERT INTO ddbba.usuario(id_paciente,contraseña,fecha_creacion)
	VALUES(@id_paciente,@contraseñas,@fecha_creacion)
END;


--Insertar Paciente
GO
CREATE PROC dbproc.insertPaciente(@nombre varchar(30),@apellido varchar(30),@apellido_materno varchar(30),@fecha_nacimiento date,
							@tipo_documento varchar(8),@dni int,@sexo_biologico varchar(10),@genero varchar(7),@nacionalidad varchar(30),
							@foto_de_perfil varchar(200),@mail varchar(40),@telefono_fijo varchar(20),@telefono_alternativo varchar(20),
							@telefono_laboral varchar(20),@usuario_actualizacion varchar(20))
AS
BEGIN
	--validaciones
	IF (@nombre IS NULL OR @apellido IS NULL OR @tipo_documento IS NULL OR @dni IS NULL OR @telefono_fijo IS NULL)
    BEGIN
        RAISERROR('Los campos nombre, apellido, tipo de documento, DNI y teléfono fijo no pueden ser nulos.', 16, 1);
        RETURN;
    END
    IF (@sexo_biologico NOT IN ('Masculino', 'Femenino'))
    BEGIN
        RAISERROR('El valor de sexo_biologico debe ser "Masculino" o "Femenino".', 16, 1);
        RETURN;
    END
    IF (@genero NOT IN ('Hombre', 'Mujer', 'Trans'))
    BEGIN
        RAISERROR('El valor de genero debe ser "Hombre", "Mujer" o "Trans".', 16, 1);
        RETURN;
    END
    IF (@dni <= 0)
    BEGIN
        RAISERROR('El valor de DNI debe ser un número positivo.', 16, 1);
        RETURN;
    END

    IF (@fecha_nacimiento > GETDATE())
    BEGIN
        RAISERROR('La fecha no puede ser en el futuro.', 16, 1);
        RETURN;
    END
    IF (@mail IS NOT NULL AND @mail NOT LIKE '%@%.%')
    BEGIN
        RAISERROR('El formato del correo electrónico no es válido.', 16, 1);
        RETURN;
    END
    IF (LEN(@telefono_fijo) > 20 OR LEN(@telefono_alternativo) > 20 OR LEN(@telefono_laboral) > 20)
    BEGIN
        RAISERROR('Los números de teléfono no deben exceder los 20 caracteres.', 16, 1);
        RETURN;
    END
	--insercion
	INSERT INTO ddbba.paciente (nombre,apellido,apellido_materno,fecha_nacimiento,tipo_documento,dni,sexo_biologico,genero,
									nacionalidad,foto_de_perfil, mail,telefono_fijo,telefono_alternativo,telefono_laboral,usuario_actualizacion)
	VALUES (@nombre,@apellido,@apellido_materno,@fecha_nacimiento,@tipo_documento,@dni,@sexo_biologico,@genero,@nacionalidad,
				@foto_de_perfil,@mail, @telefono_fijo, @telefono_alternativo,@telefono_laboral,@usuario_actualizacion)

END;

--Insertar Cobertura
GO
CREATE PROC dbproc.insertCobertura(@id_Cobertura int,@id_Prestador int,@imagen_credencial varchar(200),@nro_socio int,@fecha_registro date)
AS
BEGIN
	--validaciones
	IF (@id_Cobertura IS NULL OR @id_Prestador IS NULL OR @nro_socio IS NULL)
    BEGIN
        RAISERROR('Los campos id_Cobertura, id_Prestador y nro_socio no pueden ser nulos.', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.paciente WHERE id_Historia_Clinica = @id_Cobertura)
    BEGIN
        RAISERROR('El id_Cobertura no existe en la tabla paciente.', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.prestador WHERE id_prestador = @id_Prestador)
    BEGIN
        RAISERROR('El id_Prestador no existe en la tabla prestador.', 16, 1);
        RETURN;
    END
    IF (@nro_socio <= 0)
    BEGIN
        RAISERROR('El nro_socio debe ser un número positivo.', 16, 1);
        RETURN;
    END
    IF (@fecha_registro > GETDATE())
    BEGIN
        RAISERROR('La fecha de registro no puede ser en el futuro.', 16, 1);
        RETURN;
    END
	--insercion
	INSERT INTO ddbba.cobertura(id_Cobertura,id_Prestador,imagen_credencial,nro_socio,fecha_registro)
	VALUES(@id_Cobertura,@id_Prestador,@imagen_credencial,@nro_socio,@fecha_registro)
END;


--Insertar Domicilio
GO
CREATE PROC dbproc.insertDomicilio(@id_paciente int, @calle VARCHAR(20),@nro INT,@piso INT, @departamento CHAR(5), @cod_postal CHAR(5),
								@pais VARCHAR(30), @provincia VARCHAR(20),@localidad VARCHAR(30))
AS
BEGIN
	--validaciones
    IF  @id_paciente IS NULL OR @calle IS NULL OR @nro IS NULL OR @localidad IS NULL
    BEGIN
        RAISERROR ('Los campos id_paciente, calle, nro, localidad son obligatorios', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.paciente WHERE id_Historia_Clinica = @id_paciente)
    BEGIN
        RAISERROR ('El id_paciente no existe en la tabla paciente', 16, 1);
        RETURN;
    END
    IF LEN(@cod_postal) <> 4
    BEGIN
        RAISERROR ('El código postal debe tener 4 caracteres', 16, 1);
        RETURN;
    END
    IF @nro <= 0
    BEGIN
        RAISERROR ('El número de calle debe ser positivo', 16, 1);
        RETURN;
    END
	--insercion
    INSERT INTO ddbba.domicilio (id_paciente,calle,nro,piso,departamento,cod_postal,pais,provincia,localidad )
    VALUES (@id_paciente, @calle,@nro,@piso, @departamento, @cod_postal, @pais, @provincia, @localidad )
END;

--Insertar Prestador
GO
CREATE PROCEDURE dbproc.insertPrestador (@nombre_prestador VARCHAR(30), @plan_prestador VARCHAR(30))
AS
BEGIN
	IF  @nombre_prestador IS NULL OR @plan_prestador IS NULL 
    BEGIN
        RAISERROR ('Los campos nombre_prestador, plan_prestador son obligatorios', 16, 1);
        RETURN;
    END
    INSERT INTO ddbba.prestador (nombre_prestador, plan_prestador)
    VALUES ( @nombre_prestador, @plan_prestador )
END;


--Insertar Estudio
GO
CREATE PROCEDURE dbproc.insertEstudio (@id_paciente int, @fecha DATE,@nombre_estudio VARCHAR(50), @autorizado VARCHAR(10),
								@documento_resultado VARCHAR(200),@imagen_resultado VARCHAR(200))
AS
BEGIN
	IF  @id_paciente IS NULL OR @nombre_estudio IS NULL OR @fecha IS NULL 
    BEGIN
        RAISERROR ('Los campos id_paciente, nombre_estudio y fecha son obligatorios', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM ddbba.paciente WHERE id_Historia_Clinica = @id_paciente)
    BEGIN
        RAISERROR ('El id_paciente no existe en la tabla paciente', 16, 1);
        RETURN;
    END
	IF (@fecha > GETDATE())
    BEGIN
        RAISERROR('La fecha no puede ser en el futuro.', 16, 1);
        RETURN;
    END
    INSERT INTO ddbba.estudio (id_paciente,fecha,nombre_estudio, autorizado, documento_resultado,imagen_resultado )
    VALUES ( @id_paciente,@fecha,@nombre_estudio, @autorizado, @documento_resultado,@imagen_resultado)
END;


--Insertar Sede
GO
CREATE PROCEDURE dbproc.insertSedeDeAtencion (@nombre_sede VARCHAR(40),@direccion VARCHAR(30), @localidad varchar(30),@provincia varchar(30))
AS
BEGIN
	IF  @nombre_sede IS NULL OR @direccion IS NULL OR @localidad IS NULL OR @provincia IS NULL 
    BEGIN
        RAISERROR ('Los campos nombre_sede, direccion, provincia y localidad son obligatorios', 16, 1);
        RETURN;
    END
    INSERT INTO ddbba.sedeDeAtencion (nombre_sede, direccion,localidad, provincia)
    VALUES ( @nombre_sede,@direccion,@localidad,@provincia )
END;


--Insertar Medico
GO
CREATE PROCEDURE dbproc.insertMedico ( @id_especialidad int,@nombre VARCHAR(30), @apellido VARCHAR(30), @nro_matricula INT)
AS
BEGIN
	IF  @id_especialidad IS NULL OR @nombre IS NULL OR @apellido IS NULL 
    BEGIN
        RAISERROR ('Los campos id_especialidad, nombre y apellido son obligatorios', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM ddbba.especialidad WHERE id_especialidad = @id_especialidad)
    BEGIN
        RAISERROR('La especialidad no existe.', 16, 1)
        RETURN;
    END
	IF EXISTS (SELECT 1 FROM ddbba.medico WHERE nro_matricula = @nro_matricula)
    BEGIN
        RAISERROR('El número de matrícula ya existe.', 16, 1)
        RETURN;
    END
    INSERT INTO ddbba.medico (id_especialidad,nombre, apellido, nro_matricula )
    VALUES ( @id_especialidad, @nombre, @apellido, @nro_matricula)
END;

--Insertar DiasXSede
GO
CREATE PROCEDURE dbproc.insertDiasXSede ( @id_sede INT,@id_medico INT,@dia varchar(15),@hora_inicio TIME)
AS
BEGIN
	--validaciones
	IF  @id_sede IS NULL OR @id_medico IS NULL 
    BEGIN
        RAISERROR ('Los campos id_sede, id_medico son obligatorios', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM ddbba.sedeDeAtencion WHERE id_sede = @id_sede)
    BEGIN
        RAISERROR('La sede de atención no existe.', 16, 1)
        RETURN
    END
	IF NOT EXISTS (SELECT 1 FROM ddbba.medico WHERE id_medico = @id_medico)
    BEGIN
        RAISERROR('El médico no existe.', 16, 1)
        RETURN
    END
	IF @dia NOT IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo')
    BEGIN
        RAISERROR('El día proporcionado no es válido. Debe ser uno de los días de la semana (Lunes, Martes, Miércoles, Jueves, Viernes, Sábado, Domingo).', 16, 1)
        RETURN
    END
	--insercion
    INSERT INTO ddbba.diasXSede (id_sede,id_medico, dia,hora_inicio)
    VALUES (@id_sede,@id_medico,@dia,@hora_inicio)
END;


--Insertar Especialidad
GO
CREATE PROCEDURE dbproc.insertEspecialidad ( @nombre_especialidad VARCHAR(30))
AS
BEGIN
	IF @nombre_especialidad IS NULL 
    BEGIN
        RAISERROR ('El campo nombre_especialidad es obligatorio', 16, 1);
        RETURN;
    END
    INSERT INTO ddbba.especialidad (nombre_especialidad)
    VALUES (@nombre_especialidad)
END;


--Insertar TipoTurno
GO
CREATE PROCEDURE dbproc.insertTipoTurno(@tipo_turno VARCHAR(30))
AS
BEGIN
    IF @tipo_turno IN ('Virtual', 'Presencial')
		BEGIN
			INSERT INTO ddbba.tipoTurno (tipo_turno)
			VALUES (@tipo_turno)
		END
    ELSE
		BEGIN
			PRINT 'El tipo de turno no es válido. Debe ser "Virtual" o "Presencial".';
		END
END;


--Insertar EstadoTurno
GO
CREATE PROC dbproc.insertEstadoTurno(@nombre_estado VARCHAR(30))
AS
BEGIN
    IF @nombre_estado IN ('Disponible','Atendido', 'Ausente', 'Cancelado')
		BEGIN
			INSERT INTO ddbba.estadoTurno (nombre_estado)
			VALUES (@nombre_estado)
		END
    ELSE
		BEGIN
			PRINT 'El nombre del estado no es válido. Debe ser "Disponible", "Atendido", "Ausente" o "Cancelado".';
		END
END;

--Insertar ResevarTurno
GO
CREATE PROCEDURE dbproc.insertReservaTurnoMedico(@id_paciente int,@fecha DATE,@hora TIME(0),@id_medico INT,@id_especialidad INT,
											@id_direccion_atencion INT,@id_estado_turno INT, @id_tipo_turno INT)
AS
BEGIN
	--validaciones
	IF  @id_paciente IS NULL OR @fecha IS NULL OR @hora IS NULL OR @id_medico IS NULL OR @id_direccion_atencion IS NULL 
    BEGIN
        RAISERROR ('Los campos id_paciente, fecha, hora, id_medico y id_direccion_atencion son obligatorios', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM ddbba.paciente WHERE id_Historia_Clinica = @id_paciente)
    BEGIN
        RAISERROR('El paciente no existe.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.medico WHERE id_medico = @id_medico)
    BEGIN
        RAISERROR('El médico no existe.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.especialidad WHERE id_especialidad = @id_especialidad)
    BEGIN
        RAISERROR('La especialidad no existe.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.sedeDeAtencion WHERE id_sede = @id_direccion_atencion)
    BEGIN
        RAISERROR('La sede no existe.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.estadoTurno WHERE id_estado = @id_estado_turno)
    BEGIN
        RAISERROR('El estado del turno no existe.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (SELECT 1 FROM ddbba.tipoTurno WHERE id_tipo_turno = @id_tipo_turno)
    BEGIN
        RAISERROR('El tipo de turno no existe.', 16, 1)
        RETURN
    END
    -- Validar que la hora sean cada 15 minutos
    IF DATEDIFF(MINUTE, '00:00:00', @hora) % 15 <> 0
    BEGIN
        RAISERROR('La hora debe ser cada 15 minutos.', 16, 1)
        RETURN
    END
	--validar la disponibilidad del medico para ese turno
    IF EXISTS (SELECT 1 FROM ddbba.reservaTurnoMedico 
               WHERE id_medico = @id_medico 
                 AND fecha = @fecha 
                 AND hora = @hora)
    BEGIN
        RAISERROR('El médico ya tiene un turno reservado en esa fecha y hora.', 16, 1)
        RETURN
    END
    -- validar la disponibilidad del paciente para ese turno
    IF EXISTS (SELECT 1 FROM ddbba.reservaTurnoMedico 
               WHERE id_paciente = @id_paciente 
                 AND fecha = @fecha 
                 AND hora = @hora)
    BEGIN
        RAISERROR('El paciente ya tiene un turno reservado en esa fecha y hora.', 16, 1)
        RETURN
    END
	--insercion
    INSERT INTO ddbba.reservaTurnoMedico (id_paciente,fecha,hora,id_medico,id_especialidad,id_direccion_atencion,id_estado_turno,id_tipo_turno)
    VALUES (@id_paciente,@fecha,@hora,@id_medico,@id_especialidad,@id_direccion_atencion,@id_estado_turno,@id_tipo_turno)
END
GO
