Nombre del proyecto: EcoPulse

    Indicaciones para lenvatar el Backend:
    1.Crear un entorno virtual antes de entrar a la carpeta backend e instalar lo siguiente:
    fastapi uvicorn sqlalchemy  pydantic    python-jose[cryptography]  
    passlib[bcrypt] python-multipart
    
    2.Navegar hasta ubicarse en la carpeta ..\bakend\app
    3.Ya ubicado ejecutar en consola: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    4.Escribir la siguiente URL en el navegador : http://localhost:8000
    5.En este punto ya se puede saber si el servidor se levanto, 
    recorar que el manejo de ciertos endpoints requiere de autenticación.
