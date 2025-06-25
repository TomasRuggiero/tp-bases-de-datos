

-------- SCRIPT CREACION BI --------

-------- CREACION TABLA DIMENSIONES --------

use GD1C2025

CREATE TABLE THIS_IS_FINE.BI_tiempo (
	tiempo_codigo INT IDENTITY(1,1),
	tiempo_anio INT,
	tiempo_cuatrimestre INT,
	tiempo_mes INT
	CONSTRAINT PK_tiempo PRIMARY KEY (tiempo_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_ubicacion (
	ubicacion_codigo INT IDENTITY(1,1),
	ubicacion_provincia NVARCHAR(255),
	ubicacion_localidad NVARCHAR(255)
	CONSTRAINT PK_ubicacion PRIMARY KEY (ubicacion_codigo)   
)

CREATE TABLE THIS_IS_FINE.BI_rango_etario (
	rango_etario_codigo INT IDENTITY(1,1),
	rango NVARCHAR(50)
	CONSTRAINT PK_rango_etario PRIMARY KEY (rango_etario_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_turno_ventas (
	turno_codigo INT IDENTITY(1,1),
	turno NVARCHAR(50)
	CONSTRAINT PK_turno_ventas PRIMARY KEY (turno_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_tipo_material(
	tipo_material_codigo INT IDENTITY(1,1),
	tipo_material NVARCHAR(255),
	material_descripcion NVARCHAR(255)
	CONSTRAINT PK_tipo_material PRIMARY KEY (tipo_material_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_modelo_sillon(
	modelo_codigo INT IDENTITY(1,1),
	modelo_descripcion NVARCHAR(255)
	CONSTRAINT PK_modelo_sillon PRIMARY KEY (modelo_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_estado_pedido(
	estado_codigo INT IDENTITY(1,1),
	estado NVARCHAR(255)
	CONSTRAINT PK_estado_pedido PRIMARY KEY (estado_codigo)
)	

CREATE TABLE THIS_IS_FINE.BI_sucursal(
	sucursal_codigo INT IDENTITY(1,1),
	sucursal_ubicacion INT
	CONSTRAINT PK_sucursal PRIMARY KEY (sucursal_codigo)
	CONSTRAINT FK_sucursal_ubicacion FOREIGN KEY (sucursal_ubicacion)
		REFERENCES THIS_IS_FINE.BI_ubicacion (ubicacion_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_Pedido(
	pedido_id INT,
	pedido_sucursal INT,
	pedido_tiempo INT,
	pedido_rango_etario INT,
	pedido_turno_ventas INT,
	pedido_modelo_sillon INT,
	pedido_estado INT,
	pedido_fecha datetime2(6),
	pedido_cantidad INT,
	pedido_precio_total decimal(18,2),

	CONSTRAINT PK_Hecho_pedido PRIMARY KEY (pedido_id),

	CONSTRAINT FK_Hecho_Pedido_sucursal FOREIGN KEY (pedido_sucursal)
		REFERENCES THIS_IS_FINE.BI_sucursal (sucursal_codigo),
	CONSTRAINT FK_Hecho_Pedido_tiempo FOREIGN KEY (pedido_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_codigo),
	CONSTRAINT FK_Hecho_Pedido_rango_etario FOREIGN KEY (pedido_rango_etario)
		REFERENCES THIS_IS_FINE.BI_rango_etario (rango_etario_codigo),
	CONSTRAINT FK_Hecho_Pedido_horario_ventas FOREIGN KEY (pedido_turno_ventas)
		REFERENCES THIS_IS_FINE.BI_turno_ventas (turno_codigo),
	CONSTRAINT FK_Hecho_Pedido_modelo_sillon FOREIGN KEY (pedido_modelo_sillon)
		REFERENCES THIS_IS_FINE.BI_modelo_sillon (modelo_codigo),
	CONSTRAINT FK_Hecho_Pedido_estado FOREIGN KEY (pedido_estado)
		REFERENCES THIS_IS_FINE.BI_estado_pedido (estado_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_factura(
	factura_sucursal INT,
	factura_tiempo INT,
	factura_modelo_sillon INT,
	factura_cantidad INT,
	factura_fecha datetime2(6),
	factura_total decimal(12,2)
	CONSTRAINT PK_Hecho_Factura PRIMARY KEY (factura_sucursal, factura_tiempo, factura_modelo_sillon)
	CONSTRAINT FK_Hecho_Factura_sucursal FOREIGN KEY (factura_sucursal)
		REFERENCES THIS_IS_FINE.BI_sucursal (sucursal_codigo),
	CONSTRAINT FK_Hecho_Factura_tiempo FOREIGN KEY (factura_tiempo)
		REFERENCES THIS_IS_FINE.BI_tiempo (tiempo_codigo),
	CONSTRAINT FK_Hecho_Factura_modelo_sillon FOREIGN KEY (factura_modelo_sillon)
		REFERENCES THIS_IS_FINE.BI_modelo_sillon (modelo_codigo)
)

CREATE TABLE THIS_IS_FINE.BI_Hecho_







