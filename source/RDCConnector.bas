B4J=true
Group=Connector
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
'Class module
Sub Class_Globals
	#If SQLite or Dbf or Firebird
	Private db As SQL
	#Else
	Private pool As ConnectionPool
	#End If
	Private mDbType As String
	Private mDbDir As String 'ignore
	Private mDbFile As String 'ignore
	Private mDbName As String 'ignore
	Private mDbUser As String 'ignore
	Private mDbPassword As String 'ignore
	Private mJdbcUrl As String 'ignore
	Private mDriverClass As String 'ignore
	#If Dbf
	Private h2 As SQL
	Private mJdbcUrl2 As String
	Private mDriverClass2 As String
	#End If
	Private mConfig As Map
	Private mCommands As Map
	Private mServerPort As Int
	Private mConfigFile As String
	Private mConfigFolder As String
	Private DebugQueries As Boolean
End Sub

Public Sub Initialize (ConfigFolder As String, ConfigFile As String)
	#If MSSQL
	mDbType = "MSSQL"
	#Else If MySQL
	mDbType = "MySQL"
	#Else If Firebird
	mDbType = "Firebird"
	#Else If Postgresql
	mDbType = "Postgresql"
	#Else If Dbf
	mDbType = "DBF"
	#Else
	mDbType = "SQLite"
	#End If
	mConfigFolder = ConfigFolder
	mConfigFile = ConfigFile
	mConfig = LoadConfigMap
	mDbDir = mConfig.Get(mDbType & ".DBDir")
	If mDbDir.Trim = "" Then mDbDir = File.DirApp
	mDbFile = mConfig.Get(mDbType & ".DBFile")
	mDbName = mConfig.Get(mDbType & ".DBName")
	mDbUser = mConfig.Get(mDbType & ".User")
	mDbPassword = mConfig.Get(mDbType & ".Password")
	mJdbcUrl = mConfig.Get(mDbType & ".JdbcUrl")
	mDriverClass = mConfig.Get(mDbType & ".DriverClass")
	#If Dbf
	mJdbcUrl2 = mConfig.Get(mDbType & ".JdbcUrl2")
	mDriverClass2 = mConfig.Get(mDbType & ".DriverClass2")
	#End If
	#If DEBUG
	DebugQueries = True
	#Else
	DebugQueries = False
	#End If
	mServerPort = mConfig.GetDefault("ServerPort", 17178)
	LoadSQLCommands
	CheckDatabase
End Sub

#If Dbf or Firebird or SQLite
Private Sub InitializeDatabase
	#If Dbf
	db.Initialize(mDriverClass, mJdbcUrl.Replace("{DBDir}", mDbDir))
	h2.Initialize(mDriverClass2, mJdbcUrl2)
	#Else If Firebird
	db.Initialize2(mDriverClass, mJdbcUrl.Replace("{DBDir}", mDbDir).Replace("{DBFile}", mDbFile), mDbUser, mDbPassword)
	#Else If SQLite
	db.InitializeSQLite(mDbDir, mDbFile, False)
	#End If
End Sub
#Else
' Initialize Connection Pool
Private Sub	InitializePool
	pool.Initialize(mDriverClass, mJdbcUrl.Replace("{DBName}", mDbName), mDbUser, mDbPassword)
End Sub
#End If

Private Sub LoadConfigMap As Map
	Return File.ReadMap(mConfigFolder, mConfigFile)
End Sub

' Use for common queries with key starts with SQL.
Public Sub GetCommand (Key As String) As String
	If mCommands.ContainsKey(Key) = False Then
		Log("*** Command not found: " & Key)
	End If
	Return mCommands.Get(Key)
End Sub

Public Sub GetConnection As SQL
	If DebugQueries Then ReloadSQLCommands
	#If SQLite or DBF or Firebird
	InitializeDatabase
	Return db
	#Else
	Return pool.GetConnection
	#End If
End Sub

#If Dbf
' H2 database
Public Sub GetConnection2 As SQL
	Return h2
End Sub
#End If

Public Sub getConfig As Map
	Return mConfig
End Sub

Public Sub getDbType As String
	Return mDbType
End Sub

Public Sub getServerPort As Int
	Return mServerPort
End Sub

Private Sub LoadSQLCommands
	mCommands.Initialize
	For Each Key As String In mConfig.Keys
		If Key.StartsWith(mDbType & ".SQL.") Or Key.StartsWith("SQL.") Then
			mCommands.Put(Key, mConfig.Get(Key))
		End If
	Next
End Sub

' Reloads the sql commands from the configuration file.
Public Sub ReloadSQLCommands
	mConfig = LoadConfigMap
	LoadSQLCommands
End Sub

Public Sub CheckDatabase
	Try
		Dim DBFound As Boolean
		Log($"Checking database..."$)
		#If Dbf or Firebird or SQLite
		mDbDir = mConfig.Get(mDbType & ".DBDir")
		mDbFile = mConfig.Get(mDbType & ".DBFile")
		If mDbDir.Trim = "" Then mDbDir = File.DirApp
		If File.Exists(mDbDir, mDbFile) Then
			DBFound = True
		End If
		#Else
		mDbName = mConfig.Get(mDbType & ".DBName")
		mDbUser = mConfig.Get(mDbType & ".User")
		mDbPassword = mConfig.Get(mDbType & ".Password")
		mJdbcUrl = mConfig.Get(mDbType & ".JdbcUrl")
		mDriverClass = mConfig.Get(mDbType & ".DriverClass")
		#If MySQL or Postgresql
		Dim dbschema As String = "information_schema"
		#Else If MSSQL
		Dim dbschema As String = "master"
		#End If
		Dim db As SQL
		db.Initialize2(mDriverClass, mJdbcUrl.Replace("{DBName}", dbschema), mDbUser, mDbPassword)
		If db.IsInitialized Then
			Dim strSQL As String = GetCommand($"${mDbType}.SQL.CHECK_DATABASE"$)
			Dim res As ResultSet = db.ExecQuery2(strSQL, Array As String(mDbName))
			Do While res.NextRow
				DBFound = True
			Loop
			res.Close
		End If
		#End If
		If DBFound Then
			Log("Database found!")
		Else
			Log("Creating database...")
			Select mDbType.ToLowerCase
				Case "sqlite"
					db.InitializeSQLite(mDbDir, mDbFile, True)
					db.ExecNonQuery("PRAGMA journal_mode = wal")
				Case "mysql", "mssql"
					ConAddSQLQuery(db, $"${mDbType}.SQL.CREATE_DATABASE"$)
					ConAddSQLQuery(db, $"${mDbType}.SQL.USE_DATABASE"$)
			End Select
			ConAddSQLQuery(db, $"${mDbType}.SQL.CREATE_TABLE_TBL_CATEGORY"$)
			ConAddSQLQuery(db, $"SQL.INSERT_DUMMY_TBL_CATEGORY"$)
			ConAddSQLQuery(db, $"${mDbType}.SQL.CREATE_TABLE_TBL_PRODUCTS"$)
			ConAddSQLQuery(db, $"SQL.INSERT_DUMMY_TBL_PRODUCTS"$)
			
			Dim CreateDB As Object = db.ExecNonQueryBatch("SQL")
			Wait For (CreateDB) SQL_NonQueryComplete (Success As Boolean)
			If Success Then
				Log("Database is created successfully!")
			Else
				Log("Database creation failed!")
			End If
			If db <> Null And db.IsInitialized Then db.Close
		End If
		#If MySQL or MSSQL or Postgresql
		InitializePool
		#End If
	Catch
		LogError(LastException)
		If db <> Null And db.IsInitialized Then db.Close
		Log("Error creating database!")
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub

' Add common query to create database batch with key starts with SQL. or {DBType}.SQL.
Private Sub ConAddSQLQuery (Comm As SQL, Key As String)
	Dim strSQL As String = GetCommand(Key)
	strSQL = strSQL.Replace("{DBName}", mDbName)
	Log(strSQL)
	'Comm.ExecNonQuery(strSQL) ' if not execute by batch (debug problematic query)
	If strSQL <> "" Then Comm.AddNonQueryToBatch(strSQL, Null)
End Sub