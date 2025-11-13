<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Add Student</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 18px; }
    form { max-width: 600px; }
    label { display:block; margin-top:10px; }
    input[type="text"], input[type="email"] { width: 100%; padding: 8px; box-sizing: border-box; }
    .buttons { margin-top:12px; }
    .buttons input, .buttons a { margin-right:8px; padding:8px 14px; text-decoration:none; }
    .error { color: red; font-weight: bold; }
  </style>
</head>
<body>
  <h2>Add New Student</h2>

  <form action="process_add.jsp" method="post" novalidate>
    <label>
      Student Code (required)
      <input type="text" name="student_code" required maxlength="10" />
    </label>

    <label>
      Full Name (required)
      <input type="text" name="full_name" required maxlength="100" />
    </label>

    <label>
      Email (optional)
      <input type="email" name="email" />
    </label>

    <label>
      Major (optional)
      <input type="text" name="major" maxlength="50" />
    </label>

    <div class="buttons">
      <input type="submit" value="Add Student" />
      <a href="list_students.jsp">Cancel</a>
    </div>
  </form>
</body>
</html>
