USE cureSA
GO

--RELLENAR RESTO DE TABLAS

--Tipo turno
EXEC dbproc.insertTipoTurno 'Virtual'
EXEC dbproc.insertTipoTurno 'Presencial'

--Estado turno
EXEC dbproc.insertEstadoTurno 'Atendido'
EXEC dbproc.insertEstadoTurno 'Ausente'
EXEC dbproc.insertEstadoTurno 'Cancelado'

--Usuario
GO
CREATE PROCEDURE dbproc.llenarTablaUsuario
AS
BEGIN
	--usamos el id_paciente como id_Usuario y para la contraseña
	INSERT INTO ddbba.usuario (id_paciente, contraseña, fecha_creacion)
    SELECT p.id_Historia_Clinica, CAST(p.id_Historia_Clinica AS VARCHAR(20)), GETDATE()
    FROM ddbba.paciente p
    LEFT JOIN ddbba.usuario u ON p.id_Historia_Clinica = u.id_paciente
    WHERE u.id_paciente IS NULL;
END

GO
EXEC dbproc.llenarTablaUsuario

--Cobertura
GO
CREATE PROCEDURE dbproc.llenarTablaCobertura
AS
BEGIN
    DECLARE @cant INT;
    DECLARE @cont INT = 1;
    DECLARE @id_prestador INT, @id_cobertura INT;

    SELECT @cant = COUNT(*) FROM ddbba.paciente;
    SELECT TOP 1 @id_cobertura = id_Historia_Clinica FROM ddbba.paciente ORDER BY id_Historia_Clinica ASC;
    SELECT TOP 1 @id_prestador = id_prestador FROM ddbba.prestador ORDER BY id_prestador ASC;

        WHILE @cont < @cant
        BEGIN
            DECLARE @ins_id_cobertura INT = @id_cobertura + @cont;
            DECLARE @ins_id_prestador INT = @id_prestador + CAST(RAND() * (21 - 1) + 1 AS INT);
			DECLARE @fecha DATE =GETDATE();
            EXEC dbproc.insertCobertura @ins_id_cobertura, @ins_id_prestador, NULL, @cont, @fecha
            SET @cont = @cont + 1;
        END;
END;

GO
EXEC dbproc.llenarTablaCobertura

--Estudio
GO
CREATE PROCEDURE dbproc.llenarTablaEstudio
AS
BEGIN
    DECLARE @cont INT = 1;
    DECLARE @id_prestador INT, @id_paciente INT;

    SELECT TOP 1 @id_paciente = id_Historia_Clinica FROM ddbba.paciente ORDER BY id_Historia_Clinica ASC;

        WHILE @cont <= 100
        BEGIN
            DECLARE @ins_id_paciente INT = @id_paciente + @cont;
			DECLARE @fecha DATE =GETDATE();
			DECLARE @nombre_estudio VARCHAR(100);
			SET @nombre_estudio= (SELECT TOP 1 nombre_estudio FROM ddbba.parametrosEstudios ORDER BY NEWID());

            EXEC dbproc.insertEstudio @ins_id_paciente, @fecha, @nombre_estudio,'si', NULL,NULL
            SET @cont = @cont + 1;
        END;
END;

GO
EXEC dbproc.llenarTablaEstudio

--DiasXSede
GO
CREATE PROCEDURE dbproc.llenarTablaDiasXSede
AS
BEGIN
    DECLARE @cant INT;
    DECLARE @cont INT = 0;
    DECLARE @id_sede INT, @id_medico INT;

    SELECT @cant = COUNT(*) FROM ddbba.medico;
    SELECT TOP 1 @id_sede = id_sede FROM ddbba.sedeDeAtencion ORDER BY id_sede ASC;
    SELECT TOP 1 @id_medico = id_medico FROM ddbba.medico ORDER BY id_medico ASC;
	

        WHILE @cont < @cant
        BEGIN
            DECLARE @ins_id_medico INT =  @cont;
            DECLARE @ins_id_sede INT =CAST(RAND() * (16 - 1) + 1 AS INT);
			DECLARE @dia VARCHAR(15);
			DECLARE @hora_inicio TIME;
			SET @dia = CASE CAST(RAND() * 6 AS INT)
                        WHEN 0 THEN 'Lunes'
                        WHEN 1 THEN 'Martes'
                        WHEN 2 THEN 'Miércoles'
                        WHEN 3 THEN 'Jueves'
                        WHEN 4 THEN 'Viernes'
                        WHEN 5 THEN 'Sábado'
                        WHEN 6 THEN 'Domingo'
                    END;
			SET @hora_inicio = CAST(DATEADD(HOUR, RAND() * 12, '08:00:00') AS TIME);

            EXEC dbproc.insertDiasXSede @ins_id_sede, @ins_id_medico, @dia,@hora_inicio
            SET @cont = @cont + 1;
        END;
END;

GO
EXEC dbproc.llenarTablaDiasXSede

---Turnos
GO
CREATE PROCEDURE dbproc.llenarTablaReservaTurnos
AS
BEGIN
    DECLARE @cont INT = 1;
    DECLARE @id_sede INT, @id_medico INT, @id_paciente INT,@id_especialidad INT,@id_estado_turno INT, @id_tipo_turno INT;

	SELECT TOP 1 @id_paciente = id_Historia_Clinica FROM ddbba.paciente ORDER BY id_Historia_Clinica ASC;
    SELECT TOP 1 @id_sede = id_sede FROM ddbba.sedeDeAtencion ORDER BY id_sede ASC;
    SELECT TOP 1 @id_medico = id_medico FROM ddbba.medico ORDER BY id_medico ASC;
	SELECT TOP 1 @id_especialidad = id_especialidad FROM ddbba.especialidad ORDER BY id_especialidad ASC;
	SELECT TOP 1 @id_estado_turno = id_estado FROM ddbba.estadoTurno ORDER BY id_estado ASC;
	SELECT TOP 1 @id_tipo_turno = id_tipo_turno FROM ddbba.tipoTurno ORDER BY id_tipo_turno ASC;

        WHILE @cont <= 200
        BEGIN
			DECLARE @ins_id_paciente INT = @id_paciente + CAST(RAND() * (999 - 1) + 1 AS INT);
            DECLARE @ins_id_medico INT = @id_medico + CAST(RAND() * (63 - 1) + 1 AS INT);
			DECLARE @ins_id_especialidad INT = @id_especialidad + CAST(RAND() * (17 - 1) + 1 AS INT);
            DECLARE @ins_id_sede INT = @id_sede + CAST(RAND() * (17 - 1) + 1 AS INT);
			DECLARE @ins_estado_turno VARCHAR(15)=@id_estado_turno + CAST(RAND() * (3 - 0) + 0 AS INT);
			DECLARE @ins_tipo_turno VARCHAR(15)= @id_tipo_turno + CAST(RAND() * (2 - 0) + 0 AS INT);
			DECLARE @hora TIME(0), @fecha DATE;
			SET @fecha = DATEADD(day, RAND() * (DATEDIFF(day, '2020-01-01', '2024-05-31')), '2020-01-01');
			SET @hora =DATEADD(MINUTE, CAST(RAND() * 40 AS INT) * 15, '08:00');

            EXEC dbproc.insertReservaTurnoMedico @ins_id_paciente,@fecha,@hora,@ins_id_medico,@ins_id_especialidad,@ins_id_sede,@ins_estado_turno,@ins_tipo_turno
            SET @cont = @cont + 1;
        END;
END;

GO
EXEC dbproc.llenarTablaReservaTurnos


