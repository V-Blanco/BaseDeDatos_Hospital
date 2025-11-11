USE cureSA
GO

--crea el esquema, si no existe
IF NOT EXISTS (
    SELECT schema_id FROM sys.schemas WHERE name = 'fileproc'
)
BEGIN;
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'CREATE SCHEMA fileproc;';
    EXEC sp_executesql @sql;
END;
GO

--generar archivo XML de turno para Obra Social
CREATE PROCEDURE fileproc.generarReporteTurnosAtendidos
    @nombreObraSocial VARCHAR(50), @fechaInicio DATE, @fechaFin DATE
AS
BEGIN
    DECLARE @xmlResultado XML;

    SET @xmlResultado = 
	( SELECT p.apellido AS Apellido, p.nombre AS Nombre, p.dni AS DNI, m.nombre AS NombreMedico,   m.apellido AS ApellidoMedico,
            m.nro_matricula AS Matricula,  rt.fecha AS Fecha, rt.hora AS Hora, e.nombre_especialidad AS Especialidad
        FROM ddbba.reservaTurnoMedico rt
            INNER JOIN ddbba.paciente p ON rt.id_paciente = p.id_Historia_Clinica
            INNER JOIN ddbba.medico m ON rt.id_medico = m.id_medico
            INNER JOIN ddbba.especialidad e ON rt.id_especialidad = e.id_especialidad
            INNER JOIN ddbba.cobertura c ON p.id_Historia_Clinica = c.id_Cobertura
            INNER JOIN ddbba.prestador pr ON c.id_Prestador = pr.id_prestador
        WHERE pr.nombre_prestador = @nombreObraSocial
				AND rt.fecha BETWEEN @fechaInicio AND @fechaFin
        FOR XML RAW('Turno'), ROOT('Turnos')
    );

    SELECT @xmlResultado AS ReporteTurnosAtendidos;
END;

GO
EXEC fileproc.generarReporteTurnosAtendidos 'OSDE', '2020-01-01', '2024-05-31'

