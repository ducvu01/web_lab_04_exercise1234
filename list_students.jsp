<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // DB connection settings - change to your environment
    String jdbcUrl = "jdbc:sqlserver://localhost:1434;databaseName=student_management;encrypt=false;trustServerCertificate=true";
    String dbUser = "sa";            // or your SQL login
    String dbPass = "sa"; // or empty if using integrated security with proper config

    String query = "SELECT id, student_code, full_name, email, major, created_at FROM dbo.students ORDER BY id";
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Student List</title>
    <style>
      table { border-collapse: collapse; width: 100%; max-width: 1000px; }
      th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
      th { background: #f5f5f5; }
      .error { color: red; font-weight: bold; }
    </style>
</head>
<body>
<h2>Student List</h2>

<%
    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException e) {
        out.println("<p class='error'>JDBC Driver not found. Put the Microsoft JDBC driver JAR in WEB-INF/lib.</p>");
        log("Driver error: " + e.getMessage(), e);
        return;
    }

    try (
        Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
        PreparedStatement ps = conn.prepareStatement(query);
        ResultSet rs = ps.executeQuery();
    ) {
%>

<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>Student Code</th>
            <th>Full Name</th>
            <th>Email</th>
            <th>Major</th>
            <th>Created At</th>
             
        </tr>
    </thead>
    <tbody>
    <%
        boolean hasRows = false;
        while (rs.next()) {
            hasRows = true;
    %>
        <tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("student_code") %></td>
    <td><%= rs.getString("full_name") %></td>
    <td><%= rs.getString("email") %></td>
    <td><%= rs.getString("major") %></td>
    <td><%= rs.getTimestamp("created_at") %></td>
    <td>
        <a href="delete_student.jsp?id=<%= rs.getInt("id") %>"
           class="delete-link"
           onclick="return confirm('Are you sure you want to delete this student?')"
           style="color:red;">Delete</a>
    </td>
</tr>

    <%
        }
        if (!hasRows) {
    %>
        <tr><td colspan="6">No students found.</td></tr>
    <%
        }
    %>
    </tbody>
</table>

<%
    } catch (SQLException ex) {
        out.println("<p class='error'>Database error. Please contact the administrator.</p>");
        log("SQL error while fetching students: " + ex.getMessage(), ex);
    }
%>

</body>
</html>
