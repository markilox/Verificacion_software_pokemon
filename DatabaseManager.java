package main.java.pokemon;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DatabaseManager {
    private static final Logger logger = Logger.getLogger(DatabaseManager.class.getName());

    private Connection connection;
    private String url = "jdbc:mysql://localhost:3306/CartasPokemon?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private String user = "pokemon_user";
    private String password = "12345678";

    public DatabaseManager() {
    }

    // Conectar a la base de datos
    public void connect() {
        try {
            if (connection == null || connection.isClosed()) {
            	if (url == null || user == null || password == null) {
                    logger.log(Level.SEVERE, "Error: URL, usuario o contraseña son NULL.");
                    return;
                }
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                } catch (ClassNotFoundException e) {
                    throw new RuntimeException(e);
                }
                connection = DriverManager.getConnection(url, user, password);
                logger.info("Conexión establecida con la base de datos.");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error al conectar a la base de datos", e);
	    } 
    }

    // Cerrar la conexión
    public void disconnect() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                logger.info("Conexión cerrada correctamente.");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error al cerrar la conexión", e);
        }
    }

    // Ejecutar sentencia SQL de modificación (INSERT, UPDATE, DELETE)
    public int executeUpdate(String sql) {
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            return stmt.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error ejecutando update", e);
            return -1;
        }
    }

    // Ejecutar sentencia SQL de consulta (SELECT)
    public ResultSet executeQuery(String sql) {
        try {
            PreparedStatement stmt = connection.prepareStatement(sql);
            return stmt.executeQuery();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error ejecutando consulta", e);
            return null;
        }
    }
    
    // Ejecutar sentencias SQL de modificación (INSERT, UPDATE, DELETE) dentro de una transacción
    public boolean executeTransaction(String[] sqlStatements) {
    	boolean resultado = false;
    	if (sqlStatements != null) {
	    	try {
	            connection.setAutoCommit(false); // Iniciar transacción
	                    
		        for (int i = 0; i < sqlStatements.length; i++) {
		            executeUpdate(sqlStatements[i]);
		        }
	
		        connection.commit(); // Confirmar transacción
		        logger.info("Transacción completada con éxito.");
		        resultado = true;
		            
		    } catch (SQLException e) {
		            try {
		                connection.rollback(); // Revertir cambios en caso de error
		                logger.log(Level.SEVERE, "Error en la transacción, no se ha producido ningún cambio", e);
		            } catch (SQLException rollbackEx) {
		            	logger.log(Level.SEVERE, "Error al hacer rollback", rollbackEx);
		            }
		            resultado = false;
		    } finally {
		            try {
		                connection.setAutoCommit(true); // Restaurar autocommit
		            } catch (SQLException e) {
		            	logger.log(Level.WARNING, "Error restaurando autocommit", e);
		            }
		        }
    	}//if
    	return resultado;
    }

}
