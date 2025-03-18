// manejo del form LOGIN

document.addEventListener('DOMContentLoaded', function () {
  const loginForm = document.getElementById('loginForm');

  if (loginForm) {
    loginForm.addEventListener('submit', async function (event) {
      event.preventDefault(); // Evita el envío del formulario tradicional

      const nombreusuario = document.getElementById('nombreusuario').value;
      const contrasenia = document.getElementById('password').value;
      const mensajeError = document.getElementById('mensajeError');

      try {
        const response = await axios.post('http://localhost:3300/api/login', {
          nombreusuario,
          contrasenia
        });

        if (response.data.success) {
          // Redirigir según el rol del usuario
          const posicion = response.data.posicion;
          if (posicion === 'Admin') {
            window.location.href = 'inicio.html';
          } else if (posicion === 'Empleado') {
            window.location.href = 'inicio.html';
          } else if (posicion === 'Compra') {
            window.location.href = 'inicio.html';
          } else {
            mensajeError.innerText = 'Tipo de usuario desconocido';
            mensajeError.style.display = 'block';
          }
        } else {
          // Si se recibió un mensaje que indica demasiados intentos fallidos, se agrega un hipervínculo
          if (response.data.mensaje && response.data.mensaje.includes('demasiados intentos fallidos')) {
            mensajeError.innerHTML = response.data.mensaje + '. <a href="recuperarcontrasenia.html">Recupera tu contraseña</a>';
          } else {
            mensajeError.innerText = response.data.mensaje || 'Error al iniciar sesión';
          }
          mensajeError.style.display = 'block';
        }
      } catch (error) {
        console.error('Error en el login:', error);
        mensajeError.innerText = error.response?.data?.mensaje || 'Error al iniciar sesión';
        mensajeError.style.display = 'block';
      }
    });
  }
});


//función para llenar las columnas con los datos del comprador

document.addEventListener("DOMContentLoaded", async function () {
  // Detectar perfil
  if (window.location.pathname.includes("perfil.html")) {
    try {
      const response = await fetch("http://localhost:3300/api/compradorlogin");
      const data = await response.json();

      if (!data || data.length === 0) {
        console.error("No se encontraron datos.");
        return;
      }

      // Llenar los campos con los datos obtenidos
      document.getElementById("nombre").value = data.COM_Nombre || "";
      document.getElementById("apellidos").value = data.COM_Apellido || "";
      document.getElementById("correo").value = data.US_Correo || "";
      document.getElementById("direccion").value = data.COM_Direccion || "";

    } catch (error) {
      console.error("Error al obtener datos del perfil:", error);
    }
  }
});

// menejo del catologo desde la vista de los usuarios

document.addEventListener("DOMContentLoaded", async function () {
  // Verificamos si estamos en "catalogo.html"
  if (window.location.pathname.includes("catalogovistausuario.html")) {
    try {
      // 1. Pedir datos al endpoint
      const response = await fetch("http://localhost:3300/api/perifericos");
      const data = await response.json();
      console.log("Artículos recibidos:", data);

      if (!data || data.length === 0) {
        console.error("No se encontraron artículos.");
        return;
      }

      // 2. Agrupar artículos por categoría (opcional)
      const articulosPorCategoria = {};
      data.forEach(item => {
        const categoria = item["Tipo Periferico"];
        if (!articulosPorCategoria[categoria]) {
          articulosPorCategoria[categoria] = [];
        }
        articulosPorCategoria[categoria].push(item);
      });


      const catalogContainer = document.getElementById("catalogContainer");


      Object.keys(articulosPorCategoria).forEach((categoria) => {
        const productos = articulosPorCategoria[categoria];

        // Para cada producto, una tarjeta colapsable
        productos.forEach((producto, index) => {
          // Generar un ID único para el collapse
          const collapseID = `${categoria}_${index}_collapse`;
          const cardHTML = `
              <div class="catalog-item mb-3 p-2 border rounded">
                <div 
                  class="catalog-item-header d-flex justify-content-between align-items-center"
                  data-bs-toggle="collapse" 
                  data-bs-target="#${collapseID}"
                  style="cursor: pointer;"
                >
                  <div>
                    <h5 class="mb-0">${categoria} - ${producto.Nombre}</h5>
                    <small>Toca aquí para desplegar</small>
                  </div>
                  <div>
                    <i class="bi bi-arrow-down-square-fill me-2"></i>
                    <i class="bi bi-image"></i>
                  </div>
                </div>
                <div id="${collapseID}" class="collapse mt-2">
                  <div class="catalog-content">
                    <div class="d-flex align-items-center justify-content-between">
                      <div>
                        <p class="mb-1"><strong>Descripción:</strong> ${producto.Descripcion}</p>
                        <p class="mb-1"><strong>Precio:</strong> $${producto.Precio.toFixed(2)}</p>
                      </div>
                      <button class="btn btn-primary btn-sm ms-3" onclick="window.location.href='carritocompras.html?nombre=${encodeURIComponent(producto.Nombre)}'">Comprar</button>

                    </div>
                  </div>
                </div>
              </div>
            `;
          // Insertar la tarjeta en el contenedor general
          catalogContainer.innerHTML += cardHTML;
        });
      });

    } catch (error) {
      console.error("Error al cargar el catálogo:", error);
    }
  }
});


// función para llamar sp de faq

document.addEventListener("DOMContentLoaded", async function () {
  // Verifica que estamos en la página FAQ (ajusta el nombre según corresponda)
  if (window.location.pathname.includes("faq.html")) {
    try {
      // Hacer fetch al endpoint de FAQ
      const response = await fetch("http://localhost:3300/api/faq");
      const data = await response.json();
      console.log("FAQs recibidas:", data);

      // Seleccionar el contenedor de FAQ
      const faqContainer = document.querySelector(".faq-items");
      if (!faqContainer) {
        console.error("No se encontró el contenedor de FAQ (.faq-items)");
        return;
      }

      // resetear contenido
      faqContainer.innerHTML = "";

      // Iterar sobre cada objeto FAQ (asumiendo que cada objeto tiene la propiedad "Pregunta")
      data.forEach(item => {
        // Crear un div para cada FAQ
        const faqItem = document.createElement("div");
        faqItem.classList.add("faq-item", "mb-2", "p-2");

        faqItem.innerHTML = `
            <h6 class="mb-1">${item.Pregunta}</h6>
    //        <p class="mb-0 text-muted">Respuesta: ...</p>
          `;
        // Insertar el FAQ en el contenedor
        faqContainer.appendChild(faqItem);
      });
    } catch (error) {
      console.error("Error al cargar las FAQs:", error);
    }
  }
});


// historial

document.addEventListener("DOMContentLoaded", async function () {
  // Verificamos si estamos en la página de historial (ajusta el criterio según el nombre de tu archivo)
  if (window.location.pathname.includes("historial.html")) {
    try {
      // 1. Obtener los datos del historial desde el endpoint
      const response = await fetch("http://localhost:3300/api/historialcomprador");
      const data = await response.json();
      console.log("Historial de compras recibido:", data);

      if (!data || data.length === 0) {
        console.error("No se encontraron registros de historial.");
        return;
      }

      // 2. Seleccionar el contenedor donde se mostrarán los items
      const historyContainer = document.querySelector(".history-items");

      historyContainer.innerHTML = "";

      // 3. Iterar sobre cada registro del historial y generar el HTML
      data.forEach(item => {

        const idFactura = item["ID Factura"] || item.id_factura || "Sin ID";
        const articulo = item["Articulo"] || "Sin artículo";
        const precio = item["Precio item"] || item.precio_item || 0;
        const fecha = item["Fecha"] || "Sin fecha";
        const detalle = item["Detalle compra"] || item.detalle_compra || "Sin detalle";
        const personalizaciones = item["Personalizaciones"] || "Sin personalizaciones";

        // html
        const historyHTML = `
            <div class="history-item d-flex justify-content-between align-items-center mb-3 p-2 border rounded">
              <div>
                <h6 class="mb-0">Factura: ${idFactura}</h6>
                <small class="text-muted">Artículo: ${articulo}</small><br>
                <small class="text-muted">Detalle: ${detalle}</small><br>
                <small class="text-muted">Personalizaciones: ${personalizaciones}</small>
              </div>
              <div class="text-end">
                <p class="mb-0">Fecha: ${fecha}</p>
                <p class="mb-0">Precio: ₡${parseFloat(precio).toFixed(2)}</p>
              </div>
            </div>
          `;

        // insertar en el contenedor
        historyContainer.innerHTML += historyHTML;
      });

    } catch (error) {
      console.error("Error al cargar el historial:", error);
    }
  }
});

// función para obtener calificaciones

document.addEventListener("DOMContentLoaded", async function () {
  // Verifica si la ruta del archivo coincide (opcional)
  if (window.location.pathname.includes("resenias.html")) {
    try {
      //api
      const response = await fetch("http://localhost:3300/api/calificaciones");
      const data = await response.json();
      console.log("Calificaciones recibidas:", data);

      //reseñas
      const existingReviews = document.querySelector(".existing-reviews");

      existingReviews.innerHTML = "";

      // 3) Iterar sobre cada objeto devuelto por la API
      data.forEach(item => {
        const calificacion = parseInt(item.Calificacion) || 0;
        const comentario = item.Descripción || "Sin comentario";

        // Generar estrellas: si la calificación es 3, habrá 3 "bi-star-fill" y 2 "bi-star"
        let starsHTML = "";
        for (let i = 1; i <= 5; i++) {
          if (i <= calificacion) {
            starsHTML += `<i class="bi bi-star-fill"></i>`;
          } else {
            starsHTML += `<i class="bi bi-star"></i>`;
          }
        }

        const reviewHTML = `
          <div class="review-item d-flex mb-3">
            <div class="user-img me-2">
              <i class="bi bi-person fs-4"></i>
            </div>
            <div class="review-content">
              <div class="stars">
                ${starsHTML}
              </div>
              <p class="m-0">${comentario}</p>
            </div>
          </div>
        `;

        // 5) Insertar el bloque en .existing-reviews
        existingReviews.innerHTML += reviewHTML;
      });
    } catch (error) {
      console.error("Error al cargar las calificaciones:", error);
    }
  }
});


///validar la cantidad de caracteres en recuperar contraseña
document.addEventListener('DOMContentLoaded', function () {
  if (window.location.pathname.includes("recuperarcontrasenia.html")) {
    // Elementos
    const passwordField = document.getElementById('password');
    const confirmPasswordField = document.getElementById('confirmPassword');
    const mensajeError = document.getElementById('mensajeError');
    const passwordProgress = document.getElementById('passwordProgress');

    // Función para chequear fuerza de contraseña
    function checkPasswordStrength(password) {
      let score = 0;
      if (password.length >= 14) score++;
      if (/[A-Z]/.test(password)) score++;
      if (/[a-z]/.test(password)) score++;
      if (/\d/.test(password)) score++;
      if (/[!@#$%^&*()_\-+={}\[\]|\\:;"'<>,.?/`~]/.test(password)) score++;
      return score;
    }

    // Actualizar barra de progreso a medida que se escribe en la contraseña
    passwordField.addEventListener('input', function () {
      const pwdValue = passwordField.value;
      const score = checkPasswordStrength(pwdValue);
      const percentage = (score / 5) * 100; // 0, 20, 40, 60, 80, 100

      passwordProgress.style.width = percentage + '%';
      passwordProgress.setAttribute('aria-valuenow', percentage);

      // Actualizar clases según el score
      passwordProgress.classList.remove('bg-danger', 'bg-warning', 'bg-success');
      if (score <= 2) {
        passwordProgress.classList.add('bg-danger');
      } else if (score === 3) {
        passwordProgress.classList.add('bg-warning');
      } else {
        passwordProgress.classList.add('bg-success');
      }
    });

    // Manejo del Submit del formulario de registro
    crearCuentaForm.addEventListener('submit', async function (e) {
      e.preventDefault(); // Evita el envío tradicional del formulario

      // Ocultar mensaje de error anterior
      mensajeError.style.display = 'none';

      // Obtener valores

      const password = passwordField.value;
      const confirmPassword = confirmPasswordField.value;

      // Validar que ambas contraseñas coincidan
      if (password !== confirmPassword) {
        mensajeError.innerText = 'Las contraseñas no coinciden.';
        mensajeError.style.display = 'block';
        return;
      }

      // Chequear fuerza mínima de la contraseña
      const score = checkPasswordStrength(password);
      if (score < 5) {
        mensajeError.innerText = 'La contraseña no cumple todos los requisitos de seguridad.';
        mensajeError.style.display = 'block';
        return;
      }

      
    });
  }
});


document.addEventListener('DOMContentLoaded', function () {
  // Funcionalidad para la página de recuperación de contraseña
  if (window.location.pathname.includes("recuperarcontrasenia.html")) {
    const passwordField = document.getElementById("password");
    const confirmPasswordField = document.getElementById("confirmPassword");
    const mensajeError = document.getElementById("mensajeError");

    document.getElementById("btnEnviar").addEventListener("click", async (e) => {
      e.preventDefault();

      const password = passwordField.value;
      const confirmPassword = confirmPasswordField.value;

      // Validar que ambas contraseñas coincidan
      if (password !== confirmPassword) {
        mensajeError.innerText = "Las contraseñas no coinciden";
        mensajeError.style.display = "block";
        return;
      }

      if (password.length < 14) {
        mensajeError.innerText = "La contraseña debe tener al menos 14 caracteres.";
        mensajeError.style.display = "block";
        return;
      }

      try {
        const response = await axios.post('/enviar-codigo-recuperacion');

        if (response.data.success) {
          alert("Se ha enviado el código a tu correo");
          localStorage.setItem("newPassword", password);
          window.location.href = "validarcodigo.html";
        } else {
          alert("Error: " + response.data.error);
          console.debug("Detalle del error:", response.data);
        }
      } catch (error) {
        // Mostrar el error obtenido en un pop-up
        let errorMsg = error.response 
          ? (error.response.data.error || JSON.stringify(error.response.data))
          : error.message;
        console.error("Error al enviar el código:", errorMsg);
        alert("Error al enviar el código:\n" + errorMsg);
      }
    });
  }

  // Funcionalidad para la página de validación de código
  if (window.location.pathname.includes("validarcodigo.html")) {
    document.getElementById("btnCrear").addEventListener("click", async (e) => {
      e.preventDefault();

      const code = document.getElementById("validarcodigo").value;
      const newPassword = localStorage.getItem("newPassword");

      if (!newPassword) {
        alert("No se encontró la nueva contraseña. Por favor, reinicia el proceso.");
        return;
      }

      try {
        const response = await axios.post('/verificar-codigo-cambiar-pass', {
          codigo: code,
          nuevaPassword: newPassword
        });

        if (response.data.success) {
          alert("Contraseña actualizada exitosamente");
          window.location.href = "login.html";
        } else {
          alert("Error: " + response.data.error);
          console.debug("Detalle del error:", response.data);
        }
      } catch (error) {
        let errorMsg = error.response 
          ? (error.response.data.error || JSON.stringify(error.response.data))
          : error.message;
        console.error("Error al verificar el código:", errorMsg);
        alert("Error al verificar el código:\n" + errorMsg);
      }
    });
  }
});


// validar tamaño de la contraseña e insert

$(document).ready(function() {
  // Verificamos si estamos en la página de "registro.html"
  if (window.location.pathname.includes("registro.html")) {
    // Referencias a los campos del formulario
    var crearCuentaForm = $('#crearCuentaForm');
    var nombreusuarioField = $('#nombreusuario');
    var correoField = $('#correo');
    var passwordField = $('#password');
    var confirmPasswordField = $('#confirmPassword');
    var mensajeError = $('#mensajeError');
    var passwordProgress = $('#passwordProgress');

    // Referencias a los dropdowns
    var paisSelect = $('#pais');
    var provinciaSelect = $('#provincia');
    var cantonSelect = $('#canton');
    var distritoSelect = $('#distrito');

    // Variable global para almacenar la estructura completa de ubicaciones
    var ubicacionesData = [];

    // 1. Obtener la estructura JSON con todas las ubicaciones mediante AJAX
    $.ajax({
      url: 'http://localhost:3300/api/ubicaciones',
      type: 'GET',
      dataType: 'json',
      success: function(resp) {
        if(resp.success && resp.ubicaciones) {
          ubicacionesData = resp.ubicaciones; // Guardamos la data globalmente
          llenarPaises(ubicacionesData);
        } else {
          console.error("No se pudo cargar la data de ubicaciones");
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.error("Error cargando ubicaciones: " + textStatus, errorThrown);
      }
    });

    // Función para llenar el dropdown de países
    function llenarPaises(paises) {
      $.each(paises, function(i, p) {
        var option = $('<option>').val(p.id).text(p.nombre);
        paisSelect.append(option);
      });
    }

    // 2. Al cambiar el país, llenar el dropdown de provincias
    paisSelect.on('change', function() {
      provinciaSelect.empty().append($('<option>').val('').text('Seleccione una provincia'));
      cantonSelect.empty().append($('<option>').val('').text('Seleccione un cantón'));
      distritoSelect.empty().append($('<option>').val('').text('Seleccione un distrito'));

      var selectedPaisId = paisSelect.val();
      if(!selectedPaisId) return;

      var paisSeleccionado = ubicacionesData.find(function(item) {
        return item.id == selectedPaisId;
      });
      if(paisSeleccionado && paisSeleccionado.provincias) {
        $.each(paisSeleccionado.provincias, function(i, prov) {
          var option = $('<option>').val(prov.id).text(prov.nombre);
          provinciaSelect.append(option);
        });
      }
    });

    // 3. Al cambiar la provincia, llenar el dropdown de cantones
    provinciaSelect.on('change', function() {
      cantonSelect.empty().append($('<option>').val('').text('Seleccione un cantón'));
      distritoSelect.empty().append($('<option>').val('').text('Seleccione un distrito'));

      var selectedPaisId = paisSelect.val();
      var selectedProvinciaId = provinciaSelect.val();
      if(!selectedProvinciaId) return;

      var paisSeleccionado = ubicacionesData.find(function(item) {
        return item.id == selectedPaisId;
      });
      if(paisSeleccionado && paisSeleccionado.provincias) {
        var provinciaSeleccionada = paisSeleccionado.provincias.find(function(prov) {
          return prov.id == selectedProvinciaId;
        });
        if(provinciaSeleccionada && provinciaSeleccionada.cantones) {
          $.each(provinciaSeleccionada.cantones, function(i, cant) {
            var option = $('<option>').val(cant.id).text(cant.nombre);
            cantonSelect.append(option);
          });
        }
      }
    });

    // 4. Al cambiar el cantón, llenar el dropdown de distritos
    cantonSelect.on('change', function() {
      distritoSelect.empty().append($('<option>').val('').text('Seleccione un distrito'));

      var selectedPaisId = paisSelect.val();
      var selectedProvinciaId = provinciaSelect.val();
      var selectedCantonId = cantonSelect.val();
      if(!selectedCantonId) return;

      var paisSeleccionado = ubicacionesData.find(function(item) {
        return item.id == selectedPaisId;
      });
      if(paisSeleccionado && paisSeleccionado.provincias) {
        var provinciaSeleccionada = paisSeleccionado.provincias.find(function(prov) {
          return prov.id == selectedProvinciaId;
        });
        if(provinciaSeleccionada && provinciaSeleccionada.cantones) {
          var cantonSeleccionado = provinciaSeleccionada.cantones.find(function(cant) {
            return cant.id == selectedCantonId;
          });
          if(cantonSeleccionado && cantonSeleccionado.distritos) {
            $.each(cantonSeleccionado.distritos, function(i, dist) {
              var option = $('<option>').val(dist.id).text(dist.nombre);
              distritoSelect.append(option);
            });
          }
        }
      }
    });

    // 5. Función para chequear la fuerza de la contraseña
    function checkPasswordStrength(password) {
      var score = 0;
      if(password.length >= 14) score++;
      if(/[A-Z]/.test(password)) score++;
      if(/[a-z]/.test(password)) score++;
      if(/\d/.test(password)) score++;
      if(/[!@#$%^&*()_\-+={}\[\]|\\:;"'<>,.?/`~]/.test(password)) score++;
      return score;
    }

    // Actualizar la barra de progreso a medida que se escribe la contraseña
    passwordField.on('input', function() {
      var pwdValue = passwordField.val();
      var score = checkPasswordStrength(pwdValue);
      var percentage = (score / 5) * 100;
      passwordProgress.css('width', percentage + '%');
      passwordProgress.attr('aria-valuenow', percentage);

      passwordProgress.removeClass('bg-danger bg-warning bg-success');
      if(score <= 2) {
        passwordProgress.addClass('bg-danger');
      } else if(score === 3) {
        passwordProgress.addClass('bg-warning');
      } else {
        passwordProgress.addClass('bg-success');
      }
    });

    // 6. Enviar el formulario usando AJAX
    crearCuentaForm.on('submit', function(e) {
      e.preventDefault();
      mensajeError.hide();

      var nombreusuario = nombreusuarioField.val().trim();
      var correo = correoField.val().trim();
      var password = passwordField.val();
      var confirmPassword = confirmPasswordField.val();

      // Recoger los valores seleccionados de los dropdowns (se envían los IDs)
      var pais = paisSelect.val();
      var provincia = provinciaSelect.val();
      var canton = cantonSelect.val();
      var distrito = distritoSelect.val();

      // Validar que las contraseñas coincidan
      if(password !== confirmPassword) {
        mensajeError.text('Las contraseñas no coinciden.').show();
        return;
      }

      // Chequear la fuerza de la contraseña
      var score = checkPasswordStrength(password);
      if(score < 5) {
        mensajeError.text('La contraseña no cumple los requisitos de seguridad.').show();
        return;
      }

      // Enviar los datos al endpoint para crear el comprador mediante AJAX POST
      $.ajax({
        url: 'http://localhost:3300/api/insertarcomprador',
        type: 'POST',
        data: JSON.stringify({
          nombreusuario: nombreusuario,
          correo: correo,
          contrasenia: password,
          pais: pais,
          provincia: provincia,
          canton: canton,
          distrito: distrito
        }),
        contentType: 'application/json',
        dataType: 'json',
        success: function(resp) {
          console.log('Respuesta del servidor:', resp);
          if(resp.success) {
            alert('Cuenta creada exitosamente');
            
          } else {
            mensajeError.text(resp.error || 'Error al crear la cuenta.').show();
          }
        },
        error: function(jqXHR, textStatus, errorThrown) {
          console.error('Error al crear cuenta:', errorThrown);
          mensajeError.text('Error al crear la cuenta: ' + errorThrown).show();
        }
      });
    });
  }
});
