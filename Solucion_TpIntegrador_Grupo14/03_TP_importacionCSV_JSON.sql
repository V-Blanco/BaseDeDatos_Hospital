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

--EXEC fileproc.importarCSVPrestador 'RUTA'
--EXEC fileproc.importarCSVPacientes 'RUTA'
--EXEC fileproc.importarCSVSedes 'RUTA'
--EXEC fileproc.importarCSVMedicos 'RUTA'
--EXEC fileproc.importarJSONEstudios 'RUTA'

------------ CSV PRESTADOR --------------
CREATE PROCEDURE fileproc.importarCSVPrestador (@ruta VARCHAR(255))
AS
BEGIN
	create table #datosPrestadorCSV(
		nombre_prestador varchar(30),
		plan_prestador varchar(30)
	)
	DECLARE @cadSqlDinamico NVARCHAR(MAX);
	SET @cadSqlDinamico = '
	BULK INSERT #datosPrestadorCSV
	FROM ''' + @ruta + '''
	WITH
	(
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''65001'',
		FIRSTROW = 2
	)';
	EXEC sp_executesql @cadSqlDinamico;

	INSERT INTO cureSA.ddbba.prestador (nombre_prestador, plan_prestador)
	SELECT nombre_prestador,
		REPLACE(plan_prestador, ';;', '') AS plan_prestador  --para evitar que se copian los dos ;; que estan al final de cada registro
	FROM #datosPrestadorCSV AS dpc
	WHERE  NOT EXISTS (
            SELECT 1 FROM cureSA.ddbba.prestador AS p
            WHERE p.nombre_prestador = dpc.nombre_prestador
            AND REPLACE(p.plan_prestador, ';;', '') = REPLACE(dpc.plan_prestador, ';;', '') );

	truncate table #datosPrestadorCSV
END;

------------ CSV PACIENTES --------------
GO
CREATE PROCEDURE fileproc.importarCSVPacientes (@ruta VARCHAR(255))
AS
BEGIN
	create table #datosPacienteCSV(
		nombre varchar(30) not null,
		apellido varchar(30) not null,
		fecha_nacimiento varchar(10),
		tipo_documento varchar(8),
		dni int check(dni>0),
		sexo_biologico varchar(10),
		genero varchar(7),
		telefono_fijo varchar(25),
		nacionalidad varchar(30),
		mail varchar(40),
		calle_nro varchar(100),
		localidad varchar(50),
		provincia varchar(50)
	)
	DECLARE @cadSqlDinamico NVARCHAR(MAX);
	SET @cadSqlDinamico = '
	BULK INSERT #datosPacienteCSV
	FROM ''' + @ruta + '''
	WITH
	(
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''65001'',
		FIRSTROW = 2
	)';

	EXEC sp_executesql @cadSqlDinamico;
	
	--Llenar TABLA PACIENTE
	--la fecha de nacimiento la bajamos como varchar, por lo que lo convertimos a date para insertar en pacinete
	INSERT INTO ddbba.paciente ( nombre, apellido, fecha_nacimiento, tipo_documento, dni, sexo_biologico,
        genero, nacionalidad,mail,telefono_fijo, fecha_de_registro, fecha_actualizacion )
    SELECT  nombre, apellido, CONVERT(date, fecha_nacimiento, 103), tipo_documento,dni, sexo_biologico, genero,
			nacionalidad, mail,telefono_fijo, GETDATE(), GETDATE() 
    FROM #datosPacienteCSV AS dpc
    WHERE NOT EXISTS (
        SELECT 1 FROM ddbba.paciente AS p
        WHERE p.dni = dpc.dni);

	--Llenar TABLA DOMICILIO
	INSERT INTO ddbba.domicilio (id_paciente, calle, nro, localidad, provincia)
	SELECT 
		p.id_Historia_Clinica,
		--Separa a partir del primer espacio ' ' contando desde el final (reverse)
		--El rtrim elimina, si hay, los espacio al final (para los registros que tienen un espacio dsp del numero)
		--Se guarda mal cuando no hay numero (ej:Graham bell ) (el primer espacio que encuentra va hacer en el nombre de la calle) 
		LEFT(dpc.calle_nro, LEN(dpc.calle_nro) - CHARINDEX(' ', REVERSE(RTRIM(dpc.calle_nro)))) AS calle,
		RIGHT(dpc.calle_nro, CHARINDEX(' ', REVERSE(RTRIM(dpc.calle_nro))) - 1) AS numero,
		dpc.localidad,dpc.provincia
	FROM #datosPacienteCSV AS dpc
		INNER JOIN ddbba.paciente p ON dpc.dni = p.dni
	WHERE NOT EXISTS (
        SELECT 1 FROM ddbba.domicilio AS d
        WHERE d.id_paciente = p.id_Historia_Clinica);

	TRUNCATE TABLE #datosPacienteCSV
END;

------------  CSV SEDES  --------------
GO
CREATE PROCEDURE fileproc.importarCSVSedes (@ruta VARCHAR(255))
AS
BEGIN
	CREATE TABLE #datosSedesrCSV(
		nombre_sede varchar(40),
		direccion varchar(50),
		localidad varchar(30),
		provincia varchar(30)
	)
	DECLARE @cadSqlDinamico NVARCHAR(MAX);
	SET @cadSqlDinamico = '
	BULK INSERT #datosSedesrCSV
	FROM ''' + @ruta + '''
	WITH
	(
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''65001'',
		FIRSTROW = 2
	)';
	EXEC sp_executesql @cadSqlDinamico;

	INSERT INTO cureSA.ddbba.sedeDeAtencion (nombre_sede, direccion,localidad,provincia)
	SELECT nombre_sede, direccion,localidad,provincia
	FROM #datosSedesrCSV AS dsc
    WHERE NOT EXISTS (
        SELECT 1 FROM ddbba.sedeDeAtencion AS sda
        WHERE sda.nombre_sede = dsc.nombre_sede
        AND sda.direccion = dsc.direccion
        AND sda.localidad = dsc.localidad
        AND sda.provincia = dsc.provincia);

	truncate table #datosSedesrCSV
END;

------------ CSV MEDICOS --------------
GO
CREATE PROCEDURE fileproc.importarCSVMedicos (@ruta VARCHAR(255))
AS
BEGIN
	create table #datosMedicosCSV(
		apellido varchar(30),
		nombre varchar(30),
		especialidad varchar(30),
		nro_matricula int
	)
	DECLARE @cadSqlDinamico NVARCHAR(MAX);
	SET @cadSqlDinamico = '
	BULK INSERT #datosMedicosCSV
	FROM ''' + @ruta + '''
	WITH
	(
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''65001'',
		FIRSTROW = 2
	)';
	EXEC sp_executesql @cadSqlDinamico;

	INSERT INTO cureSA.ddbba.especialidad (nombre_especialidad)
	SELECT DISTINCT especialidad 
	FROM #datosMedicosCSV AS dmc
    WHERE NOT EXISTS (
        SELECT 1 FROM cureSA.ddbba.especialidad AS e
        WHERE e.nombre_especialidad = dmc.especialidad);

	INSERT INTO ddbba.medico(id_especialidad,nombre, apellido,nro_matricula)
	SELECT e.id_especialidad , dmc.nombre, dmc.apellido, dmc.nro_matricula
	FROM #datosMedicosCSV AS dmc
		INNER JOIN ddbba.especialidad e ON e.nombre_especialidad = dmc.especialidad
	WHERE NOT EXISTS (
        SELECT 1 FROM ddbba.medico AS m
        WHERE m.nombre = dmc.nombre
        AND m.apellido = dmc.apellido
        AND m.nro_matricula = dmc.nro_matricula );

	truncate table #datosMedicosCSV
END;

--------- JSON Estudios-------------
-- Cambiamos la codificacion del archivo .json a ANSI para que registre los acentos
GO
CREATE PROCEDURE fileproc.importarJSONEstudios (@ruta VARCHAR(255))
AS
BEGIN
	DECLARE @cadSqlDinamico NVARCHAR(MAX);
	SET @cadSqlDinamico = '
		INSERT INTO ddbba.parametrosEstudios (id_estudio,area,nombre_estudio,nombre_prestador,plan_prestador,costo,porcentaje_cobertura,autorizacion)
		SELECT id_estudio,area,nombre_estudio,nombre_prestador,plan_prestador,costo,[Porcentaje Cobertura],[Requiere autorizacion]
		FROM OPENROWSET  (BULK ''' + @ruta + ''', SINGLE_CLOB) as j
		CROSS APPLY OPENJSON(BulkColumn)
		WITH (
			id_estudio varchar(40) ''$._id."$oid"'',
			area varchar(30) ''$.Area'',
			nombre_estudio varchar(100) ''$.Estudio'',
			nombre_prestador varchar(30) ''$.Prestador'',
			plan_prestador varchar(30) ''$.Plan'',
			costo int ''$.Costo'',
			[Porcentaje Cobertura] int,
			[Requiere autorizacion] bit
	)AS json
    WHERE NOT EXISTS (
            SELECT 1
            FROM ddbba.parametrosEstudios p
            WHERE p.id_estudio = json.id_estudio
	);';
	EXEC sp_executesql @cadSqlDinamico;
END;
GO