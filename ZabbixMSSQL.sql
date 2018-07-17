USE [master]
GO

/****** Object:  Database [DbAdmin]    Script Date: 17/07/2018 14:51:27 ******/
If(db_id(N'DbAdmin') IS NULL)
BEGIN
CREATE DATABASE [DbAdmin]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DbAdmin', FILENAME = N'DbAdmin.mdf' , SIZE = 13631488KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1048576KB )
 LOG ON 
( NAME = N'DbAdmin_log', FILENAME = N'DbAdmin.ldf' , SIZE = 6291456KB , MAXSIZE = 2048GB , FILEGROWTH = 1048576KB )
GO
END;

ALTER DATABASE [DbAdmin] SET  READ_WRITE 
GO

USE [DbAdmin]
GO

/****** Object:  StoredProcedure [dbo].[SQLReportToZabbix]    Script Date: 17/07/2018 14:53:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sergey 'dreik' Kolesnik <dreik.da@gmail.com>
-- Create date: 25/06/2018
-- =============================================

CREATE PROCEDURE [dbo].[SQLReportToZabbix] (@IncomingParam VARCHAR(MAX) = '')
AS
BEGIN

    IF @IncomingParam = 'template'
    BEGIN
		--- some sql code
    RETURN;
    END;

    IF @IncomingParam = 'Waits'
    BEGIN

	SELECT REPLACE(REPLACE(wait_type, ' ', '_'), ',', '') AS [Item], CONVERT(DECIMAL(12, 2), wait_time_ms * 100.0 / SUM(wait_time_ms) OVER ()) AS [Value]
	FROM sys.dm_os_wait_stats WITH(NOLOCK) WHERE wait_type NOT LIKE '%SLEEP%'
	UNION ALL
	SELECT 'db_perf_signal_wait_percent', CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) FROM sys.dm_os_wait_stats WITH(NOLOCK)

    RETURN;
    END;

    IF @IncomingParam = 'DBStates'
    BEGIN

	SELECT tblPivot.Item, tblPivot.Value FROM (SELECT
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 0 THEN 1 ELSE 0 END)) AS db_state_ONLINE_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 1 THEN 1 ELSE 0 END)) AS db_state_RESTORING_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 2 THEN 1 ELSE 0 END)) AS db_state_RECOVERING_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 3 THEN 1 ELSE 0 END)) AS db_state_RECOVERY_PENDING_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 4 THEN 1 ELSE 0 END)) AS db_state_SUSPECT_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 5 THEN 1 ELSE 0 END)) AS db_state_EMERGENCY_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.state = 6 THEN 1 ELSE 0 END)) AS db_state_OFFLINE_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.recovery_model = 1 THEN 1 ELSE 0 END)) AS db_recovery_model_FULL_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.recovery_model = 2 THEN 1 ELSE 0 END)) AS db_recovery_model_BULK_LOGGED_total,
		CONVERT(SQL_VARIANT, SUM(CASE WHEN d.recovery_model = 3 THEN 1 ELSE 0 END)) AS db_recovery_model_SIMPLE_total
	FROM sys.databases d WITH(NOLOCK)) DBStates
	UNPIVOT(Value FOR Item IN(db_state_ONLINE_total, db_state_RESTORING_total, db_state_RECOVERING_total, db_state_RECOVERY_PENDING_total, db_state_SUSPECT_total, db_state_EMERGENCY_total, db_state_OFFLINE_total, db_recovery_model_FULL_total, db_recovery_model_BULK_LOGGED_total,db_recovery_model_SIMPLE_total)) AS tblPivot;

        RETURN;
    END;

	IF @IncomingParam = 'dm_os_sys_memory'
    BEGIN

	SELECT tblPivot.Item, tblPivot.Value FROM (SELECT
		CONVERT(SQL_VARIANT, total_physical_memory_kb*1024) AS total_physical_memory_bytes,
		CONVERT(SQL_VARIANT, available_physical_memory_kb*1024) AS available_physical_memory_bytes,
		CONVERT(SQL_VARIANT, total_page_file_kb*1024) AS total_page_file_bytes,
		CONVERT(SQL_VARIANT, available_page_file_kb*1024) AS available_page_file_bytes,
		CONVERT(SQL_VARIANT, system_cache_kb*1024) AS system_cache_bytes,
		CONVERT(SQL_VARIANT, kernel_paged_pool_kb*1024) AS kernel_paged_pool_bytes,
		CONVERT(SQL_VARIANT, kernel_nonpaged_pool_kb*1024) AS kernel_nonpaged_pool_bytes,
		CONVERT(SQL_VARIANT, CAST(system_high_memory_signal_state AS DECIMAL(1))) AS system_high_memory_signal_state,
		CONVERT(SQL_VARIANT, CAST(system_low_memory_signal_state AS DECIMAL(1))) AS system_low_memory_signal_state
	FROM sys.dm_os_sys_memory d WITH(NOLOCK)) dm_os_sys_memory
	UNPIVOT(Value FOR Item IN(total_physical_memory_bytes, available_physical_memory_bytes, total_page_file_bytes, available_page_file_bytes, system_cache_bytes, kernel_paged_pool_bytes, kernel_nonpaged_pool_bytes, system_high_memory_signal_state, system_low_memory_signal_state)) AS tblPivot;
        
	RETURN;
    END;

	IF @IncomingParam = 'MemoryClerk'
	BEGIN

        SELECT [type] AS [Item], SUM(pages_kb) / 1024 AS [Value] FROM sys.dm_os_memory_clerks WITH (NOLOCK) GROUP BY [type];

	RETURN;
	END;

    IF @IncomingParam = 'TempDB'
    BEGIN

	SELECT tblPivot.Item, tblPivot.Value FROM (SELECT
		CONVERT(SQL_VARIANT, SUM(allocated_extent_page_count) * 8) AS tempdb_allocated_extent_page_kb,
		CONVERT(SQL_VARIANT, SUM(unallocated_extent_page_count) * 8) AS tempdb_unallocated_extent_page_kb,
		CONVERT(SQL_VARIANT, SUM(version_store_reserved_page_count) * 8) AS tempdb_version_store_reserved_page_kb,
		CONVERT(SQL_VARIANT, SUM(user_object_reserved_page_count) * 8) AS tempdb_user_object_reserved_page_kb,
		CONVERT(SQL_VARIANT, SUM(internal_object_reserved_page_count) * 8) AS tempdb_internal_object_reserved_page_kb,
		CONVERT(SQL_VARIANT, SUM(mixed_extent_page_count) * 8) AS tempdb_mixed_extent_page_kb
	FROM tempdb.sys.dm_db_file_space_usage WITH(NOLOCK)) TempDB
	UNPIVOT(Value FOR Item IN(tempdb_allocated_extent_page_kb, tempdb_unallocated_extent_page_kb, tempdb_version_store_reserved_page_kb, tempdb_user_object_reserved_page_kb, tempdb_internal_object_reserved_page_kb, tempdb_mixed_extent_page_kb)) AS tblPivot;

        RETURN;
    END;

	IF @IncomingParam = 'dm_os_schedulers'
	BEGIN

	SELECT tblPivot.Item, tblPivot.Value FROM (SELECT
		CONVERT(SQL_VARIANT, AVG(current_tasks_count)) AS db_perf_average_tasks,
		CONVERT(SQL_VARIANT, AVG(runnable_tasks_count)) AS db_perf_average_runnable_tasks,
		CONVERT(SQL_VARIANT, AVG(pending_disk_io_count)) AS db_perf_average_pending_disk_io
	FROM sys.dm_os_schedulers WITH (NOLOCK) WHERE scheduler_id < 255) dm_os_schedulers
	UNPIVOT(Value FOR Item IN(db_perf_average_tasks, db_perf_average_runnable_tasks, db_perf_average_pending_disk_io)) AS tblPivot;

	RETURN;
	END;

END;

GO


