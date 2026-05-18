import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'service_flow.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supabase_id TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        nome_completo TEXT NOT NULL,
        grupo_id TEXT NOT NULL,
        perfil TEXT DEFAULT 'tecnico',
        ultimo_login TEXT,
        avatar_local_path TEXT,
        configuracoes TEXT,
        ativo INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. clientes
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        telefone TEXT NOT NULL,
        documento TEXT,
        endereco TEXT,
        cidade TEXT,
        estado TEXT,
        cep TEXT,
        ativo INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 3. tecnicos
    await db.execute('''
      CREATE TABLE tecnicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        especialidade TEXT,
        ativo INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 4. servicos
    await db.execute('''
      CREATE TABLE servicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL,
        preco REAL NOT NULL,
        tempo_estimado TEXT,
        ativo INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 5. ordens_servico
    await db.execute('''
      CREATE TABLE ordens_servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        tecnico_id INTEGER NOT NULL,
        observacao TEXT,
        pecas_aplicadas TEXT,
        valor_pecas REAL DEFAULT 0,
        foto_antes TEXT,
        foto_depois TEXT,
        assinatura TEXT,
        ativo INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id),
        FOREIGN KEY (tecnico_id) REFERENCES tecnicos (id)
      )
    ''');

    // 6. os_itens
    await db.execute('''
      CREATE TABLE os_itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        os_id INTEGER NOT NULL,
        servico_id INTEGER NOT NULL,
        descricao_snapshot TEXT,
        preco_snapshot REAL,
        ativo INTEGER DEFAULT 1,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (os_id) REFERENCES ordens_servico (id),
        FOREIGN KEY (servico_id) REFERENCES servicos (id)
      )
    ''');

    // 7. system_logs
    await db.execute('''
      CREATE TABLE system_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level TEXT NOT NULL,
        source TEXT NOT NULL,
        operation TEXT NOT NULL,
        message TEXT NOT NULL,
        metadata TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}
