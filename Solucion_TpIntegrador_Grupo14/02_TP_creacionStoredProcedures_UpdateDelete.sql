USE cureSA
GO

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

-- STORED PROCEDURES DE ACTUALIZACION Y ELIMINACION

-- las tablas paciente, prestador, estado turno, tipo turno, medico, sede de atencion y especialidad
-- no admiten borrado fisico debido a las multiples referencias que otras tablas hacen de las mismas. 
-- Eliminar fisicamente datos de estas tablas causaria inconsistencias en el resto de la base de datos.

-- MODIFICAR PACIENTE
CREATE PROCEDURE dbproc.modificarPaciente
    @IDpaciente int,
	@nombre varchar(30) = NULL,
	@apellido varchar(30) = NULL,
	@apellido_materno varchar(30) = NULL,
	@genero char(7) = NULL,
	@nacionalidad varchar(30) = NULL,
	@foto_de_perfil varchar(200) = NULL,
	@mail varchar(40) = NULL,
	@telefono_fijo varchar(20) = NULL,
	@telefono_alternativo varchar(20) = NULL,
	@telefono_laboral varchar(20) = NULL
AS
BEGIN
	BEGIN TRY

		BEGIN TRANSACTION
    
		UPDATE ddbba.paciente
		SET
			nombre = COALESCE(@nombre, nombre),
			apellido = COALESCE(@apellido, apellido),
			apellido_materno = COALESCE(@apellido_materno, apellido_materno),
			genero = CASE
						WHEN @genero IN ('Hombre','hombre','mujer', 'Mujer','Trans','trans') THEN @genero
						ELSE genero
					 END,
			nacionalidad = COALESCE(@nacionalidad, nacionalidad),
			foto_de_perfil = COALESCE(@foto_de_perfil, foto_de_perfil),
			mail = COALESCE(@mail, mail),
			telefono_fijo = COALESCE(@telefono_fijo, telefono_fijo),
			telefono_alternativo = COALESCE(@telefono_alternativo, telefono_alternativo),
			telefono_laboral = COALESCE(@telefono_laboral, telefono_laboral),
			fecha_actualizacion = getdate()
		WHERE 
			id_Historia_Clinica = @IDpaciente;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50001, 'No se encontró un paciente con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR PACIENTE (borrado lógico)
CREATE PROCEDURE dbproc.eliminarPaciente (@IDpaciente int)
AS
BEGIN
	
	UPDATE ddbba.paciente
	SET registro_eliminado = 1
	WHERE id_Historia_Clinica = @IDpaciente;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50002, 'No se encontró un paciente con el ID especificado.', 1;
    END;

END
go
  
-----------------------------------------------------------------------------------

-- MODIFICAR USUARIO
CREATE PROCEDURE dbproc.modificarUsuario(@id_Usuario int, @contraseñas varchar(50))
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
			UPDATE ddbba.usuario SET contraseña = @contraseñas
			WHERE id_Usuario = @id_Usuario
		
			IF @@ROWCOUNT = 0
			BEGIN;
				THROW 50003, 'No se encontró un usuario con el ID especificado.', 1;
			END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
		IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR USUARIO (borrado fisico)
CREATE PROCEDURE dbproc.eliminarUsuario(@id_Usuario int)
AS
BEGIN

	DELETE FROM ddbba.usuario
	WHERE id_Usuario = @id_Usuario

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50004, 'No se encontró un usuario con el ID especificado.', 1;
    END;

END;
go

-----------------------------------------------------------------------------------

-- MODIFICAR ESTUDIO
CREATE PROCEDURE dbproc.modificarEstudio
    @id_estudio int,
	@fecha date = NULL,
	@nombre_estudio varchar(30) = NULL,        
    @autorizado bit = NULL,
    @docResultado varchar(200) = NULL,
	@imgResultado varchar(200) = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
    
			UPDATE ddbba.estudio
			SET
				fecha = COALESCE(@fecha, fecha),
				nombre_estudio = COALESCE(@nombre_estudio, nombre_estudio),
				autorizado = COALESCE(@autorizado, autorizado),
				documento_resultado = COALESCE(@docResultado, documento_resultado),
				imagen_resultado = COALESCE(@imgResultado, imagen_resultado)		
			WHERE
				id_estudio = @id_estudio;
    
			IF @@ROWCOUNT = 0
			BEGIN;
				THROW 50005, 'No se encontró un estudio con el ID especificado.', 1;
			END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

	END CATCH
END;
go

-- ELIMINAR ESTUDIO (borrado fisico)
CREATE PROCEDURE dbproc.eliminarEstudio(@id_estudio int)
AS
BEGIN

	DELETE FROM ddbba.estudio
	WHERE id_estudio = @id_estudio;
	
	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50006, 'No se encontró un estudio con el ID especificado.', 1;
    END;

END;
go

-----------------------------------------------------------------------------------

-- MODIFICAR DOMICILIO
CREATE PROCEDURE dbproc.modificarDomicilio
    @id_domicilio int,
	@calle varchar(90) = NULL,
	@nro varchar(20) = NULL,
	@piso int = NULL,
	@departamento char(5) = NULL,
	@cod_postal char(5) = NULL,
	@pais varchar(30) = NULL,
	@provincia varchar(30) = NULL,
	@localidad varchar(50) = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
    
			UPDATE ddbba.domicilio
			SET
				calle = COALESCE(@calle, calle),
				nro = COALESCE(@nro, nro),
				piso = COALESCE(@piso, piso),
				departamento = COALESCE(@departamento, departamento),
				cod_postal = COALESCE(@cod_postal, cod_postal),
				pais = COALESCE(@pais, pais),
				provincia = COALESCE(@provincia, provincia),
				localidad = COALESCE(@localidad, localidad)
			WHERE
				id_domicilio = @id_domicilio;
    
			IF @@ROWCOUNT = 0
			BEGIN;
				THROW 50007, 'No se encontró un domicilio con el ID especificado.', 1;
			END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

	END CATCH
END;
go

-- ELIMINAR DOMICILIO (borrado fisico)
CREATE PROCEDURE dbproc.eliminarDomicilio(@id_domicilio int)
AS
BEGIN

	DELETE FROM ddbba.domicilio
	WHERE id_domicilio = @id_domicilio;
	
	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50008, 'No se encontró un domicilio con el ID especificado.', 1;
    END;

END;
go

-----------------------------------------------------------------------------------

-- MODIFICAR RESERVA TURNO MEDICO
CREATE PROCEDURE dbproc.modificarReservaTurno
    @id_turno int,
	@fecha date = NULL,
	@hora time(0) = NULL,
	@id_estado_turno int = NULL,
	@id_tipo_turno int = NULL
AS
BEGIN
	BEGIN TRY
		
		IF @id_estado_turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ddbba.estadoTurno WHERE id_estado = @id_estado_turno)
		BEGIN;
			THROW 50009, 'Estado de turno incorrecto.', 1;
		END;

		IF @id_tipo_turno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ddbba.tipoTurno WHERE id_tipo_turno = @id_tipo_turno)
		BEGIN;
			THROW 50010, 'Tipo de turno incorrecto.', 1;
		END;

		IF @hora IS NOT NULL AND (DATEDIFF(MINUTE, '00:00:00', @hora) % 15 != 0)
		BEGIN;
			THROW 50011, 'Horario ingresado incorrecto.', 1;
		END;

		BEGIN TRANSACTION
    
			UPDATE ddbba.reservaTurnoMedico
			SET
				fecha = COALESCE(@fecha, fecha),
				hora = COALESCE(@hora, hora),
				id_estado_turno = COALESCE(@id_estado_turno, id_estado_turno),
				id_tipo_turno = COALESCE(@id_tipo_turno, id_tipo_turno)		
			WHERE
				id_turno = @id_turno;
    
			IF @@ROWCOUNT = 0
			BEGIN;
				THROW 50012, 'No se encontró un turno con el ID especificado.', 1;
			END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

	END CATCH
END;
go

-- ELIMINAR RESERVA TURNO MEDICO (borrado fisico)
CREATE PROCEDURE dbproc.eliminarReservaTurno(@id_turno int)
AS
BEGIN

	DELETE FROM ddbba.reservaTurnoMedico
	WHERE id_turno = @id_turno;
	
	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50013, 'No se encontró un turno con el ID especificado.', 1;
    END;

END;
go

-----------------------------------------------------------------------------------

-- MODIFICAR DIAS X SEDE
CREATE PROCEDURE dbproc.modificarDiasXSede
    @id_sede int,
	@id_medico int,
	@dia varchar(15),
	@hora_inicio time(0)
AS
BEGIN
	BEGIN TRY
		
		IF NOT EXISTS (SELECT 1 FROM ddbba.sedeDeAtencion WHERE id_sede = @id_sede)
		BEGIN;
			THROW 50014, 'Estado de turno incorrecto.', 1;
		END;

		IF NOT EXISTS (SELECT 1 FROM ddbba.medico WHERE id_medico = @id_medico)
		BEGIN;
			THROW 50015, 'Tipo de turno incorrecto.', 1;
		END;

		IF (DATEDIFF(MINUTE, '00:00:00', @hora_inicio) % 15 != 0)
		BEGIN;
			THROW 50016, 'Horario ingresado incorrecto.', 1;
		END;

		BEGIN TRANSACTION
    
			UPDATE ddbba.diasXSede
			SET
				hora_inicio = @hora_inicio
			WHERE
				id_sede = @id_sede AND id_medico = @id_medico AND dia = @dia;
    
			IF @@ROWCOUNT = 0
			BEGIN;
				THROW 50017, 'Error al modificar el dia del medico en la sede', 1;
			END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

	END CATCH
END;
go

-- ELIMINAR DIAS X SEDE (borrado fisico)
CREATE PROCEDURE dbproc.eliminarDiasXSede(@id_sede int, @id_medico int, @dia varchar(15))
AS
BEGIN

	DELETE FROM ddbba.diasXSede
	WHERE id_sede = @id_sede AND id_medico = @id_medico AND dia = @dia;
	
	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50018, 'Error al eliminar el médico en la sede.', 1;
    END;

END;
go

-----------------------------------------------------------------------------------

-- MODIFICAR COBERTURA
CREATE PROCEDURE dbproc.modificarCobertura
    @id_Cobertura int,
	@id_Prestador int = NULL,
	@imagen_credencial varchar(200) = NULL,
	@nro_socio int = NULL,
	@fecha_registro date = NULL
AS
BEGIN
	BEGIN TRY
		
		IF NOT EXISTS (SELECT 1 FROM ddbba.paciente WHERE id_Historia_Clinica = @id_Cobertura)
		BEGIN;
			THROW 50019, 'ID Cobertura incorrecto.', 1;
		END;

		IF @id_Prestador IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ddbba.prestador WHERE id_prestador = @id_Prestador)
		BEGIN;
			THROW 50020, 'ID Prestador incorrecto.', 1;
		END;

		BEGIN TRANSACTION
    
		UPDATE ddbba.cobertura
		SET
			id_Prestador = COALESCE(@id_Prestador, id_Prestador),
			imagen_credencial = COALESCE(@imagen_credencial, imagen_credencial),
			nro_socio = COALESCE(@nro_socio, nro_socio),
			fecha_registro = COALESCE(@fecha_registro, fecha_registro)		
		WHERE 
			id_Cobertura = @id_Cobertura;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50021, 'No se encontró una cobertura con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR COBERTURA (borrado fisico)
CREATE PROCEDURE dbproc.eliminarCobertura (@id_Cobertura int)
AS
BEGIN
	
	DELETE FROM ddbba.cobertura
	WHERE id_Cobertura = @id_Cobertura;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50022, 'No se encontró una cobertura con el ID especificado.', 1;
    END;

END
go

-----------------------------------------------------------------------------------

-- MODIFICAR PRESTADOR
CREATE PROCEDURE dbproc.modificarPrestador
    @id_prestador int,
	@nombre_prestador varchar(30) = NULL,
	@plan_prestador varchar(30) = NULL
AS
BEGIN
	BEGIN TRY

		BEGIN TRANSACTION
    
		UPDATE ddbba.prestador
		SET
			nombre_prestador = COALESCE(@nombre_prestador, nombre_prestador),
			plan_prestador = COALESCE(@plan_prestador, plan_prestador)
		WHERE 
			id_prestador = @id_prestador;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50023, 'No se encontró un prestador con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR PRESTADOR (borrado lógico)
CREATE PROCEDURE dbproc.eliminarPrestador (@id_prestador int)
AS
BEGIN
	
	UPDATE ddbba.prestador
	SET registro_eliminado = 1
	WHERE id_prestador = @id_prestador;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50024, 'No se encontró un prestador con el ID especificado.', 1;
    END;

END
go

-----------------------------------------------------------------------------------

-- MODIFICAR ESTADO TURNO
CREATE PROCEDURE dbproc.modificarEstadoTurno
    @id_estado int,
	@nombre_estado varchar(30)
AS
BEGIN
	BEGIN TRY

		IF @nombre_estado NOT IN ('Disponible','Atendido' ,'Ausente', 'Cancelado')
		BEGIN;
			THROW 50025, 'Nombre de estado incorrecto.', 1;
		END;

		BEGIN TRANSACTION
    
		UPDATE ddbba.estadoTurno
		SET
			nombre_estado = @nombre_estado
		WHERE 
			id_estado = @id_estado;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50026, 'No se encontró un estado con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR ESTADO TURNO (borrado lógico)
CREATE PROCEDURE dbproc.eliminarEstadoTurno (@id_estado int)
AS
BEGIN
	
	UPDATE ddbba.estadoTurno
	SET registro_eliminado = 1
	WHERE id_estado = @id_estado;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50027, 'No se encontró un estado con el ID especificado.', 1;
    END;

END
go

-----------------------------------------------------------------------------------

-- MODIFICAR TIPO TURNO
CREATE PROCEDURE dbproc.modificarTipoTurno
    @id_tipo_turno int,
	@tipo_turno varchar(30)
AS
BEGIN
	BEGIN TRY

		IF @tipo_turno NOT IN ('Virtual', 'Presencial')
		BEGIN;
			THROW 50028, 'Tipo de turno incorrecto.', 1;
		END;

		BEGIN TRANSACTION
    
		UPDATE ddbba.tipoTurno
		SET
			tipo_turno = @tipo_turno
		WHERE 
			id_tipo_turno = @id_tipo_turno;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50029, 'No se encontró un tipo de turno con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR TIPO TURNO (borrado lógico)
CREATE PROCEDURE dbproc.eliminarTipoTurno (@id_tipo_turno int)
AS
BEGIN
	
	UPDATE ddbba.tipoTurno
	SET registro_eliminado = 1
	WHERE id_tipo_turno = @id_tipo_turno;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50030, 'No se encontró un tipo de turno con el ID especificado.', 1;
    END;

END
go

-----------------------------------------------------------------------------------

-- MODIFICAR SEDE DE ATENCION
CREATE PROCEDURE dbproc.modificarSedeDeAtencion
    @id_sede int,
	@nombre_sede varchar(40) = NULL,
	@direccion varchar(50) = NULL,
	@localidad varchar(30) = NULL,
	@provincia varchar(30) = NULL
AS
BEGIN
	BEGIN TRY

		BEGIN TRANSACTION
    
		UPDATE ddbba.sedeDeAtencion
		SET
			nombre_sede = COALESCE(@nombre_sede, nombre_sede),
			direccion = COALESCE(@direccion, direccion),
			localidad = COALESCE(@localidad, localidad),
			provincia = COALESCE(@provincia, provincia)
		WHERE 
			id_sede = @id_sede;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50031, 'No se encontró una sede de atención con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR SEDE DE ATENCION (borrado lógico)
CREATE PROCEDURE dbproc.eliminarSedeDeAtencion (@id_sede int)
AS
BEGIN
	
	UPDATE ddbba.sedeDeAtencion
	SET registro_eliminado = 1
	WHERE id_sede = @id_sede;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50032, 'No se encontró una sede de atención con el ID especificado.', 1;
    END;

END
go

-----------------------------------------------------------------------------------

-- MODIFICAR MEDICO
CREATE PROCEDURE dbproc.modificarMedico
    @id_medico int,
	@id_especialidad int = NULL,
	@nombre varchar(30) = NULL,
	@apellido varchar(30) = NULL,
	@nro_matricula int = NULL
AS
BEGIN
	BEGIN TRY

		IF @id_especialidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ddbba.especialidad WHERE id_especialidad = @id_especialidad)
		BEGIN;
			THROW 50033, 'ID Especialidad incorrecto.', 1;
		END;

		BEGIN TRANSACTION
    
		UPDATE ddbba.medico
		SET
			id_especialidad = COALESCE(@id_especialidad, id_especialidad),
			nombre = COALESCE(@nombre, nombre),
			apellido = COALESCE(@apellido, apellido),
			nro_matricula = COALESCE(@nro_matricula, nro_matricula)
		WHERE 
			id_medico = @id_medico;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50034, 'No se encontró un médico con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR MEDICO (borrado lógico)
CREATE PROCEDURE dbproc.eliminarMedico (@id_medico int)
AS
BEGIN
	
	UPDATE ddbba.medico
	SET registro_eliminado = 1
	WHERE id_medico = @id_medico;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50035, 'No se encontró un médico con el ID especificado.', 1;
    END;

END
go

-----------------------------------------------------------------------------------

-- MODIFICAR ESPECIALIDAD
CREATE PROCEDURE dbproc.modificarEspecialidad
    @id_especialidad int,
	@nombre_especialidad varchar(30)
AS
BEGIN
	BEGIN TRY

		BEGIN TRANSACTION
    
		UPDATE ddbba.especialidad
		SET
			nombre_especialidad = @nombre_especialidad
		WHERE 
			id_especialidad = @id_especialidad;
   
		IF @@ROWCOUNT = 0
		BEGIN;
			THROW 50036, 'No se encontró una especialidad con el ID especificado.', 1;
		END;
    
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN;
            ROLLBACK TRANSACTION;
        END;
        
        THROW;

    END CATCH;
END;
go

-- ELIMINAR ESPECIALIDAD (borrado lógico)
CREATE PROCEDURE dbproc.eliminarEspecialidad (@id_especialidad int)
AS
BEGIN
	
	UPDATE ddbba.especialidad
	SET registro_eliminado = 1
	WHERE id_especialidad = @id_especialidad;

	IF @@ROWCOUNT = 0
    BEGIN;
		THROW 50037, 'No se encontró una especialidad con el ID especificado.', 1;
    END;

END
go