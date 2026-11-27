# Cómo se publica un visual

Cada visual entra con su carpeta, su fila en la galería del README y su foto. Lo comprueba `tools/check-package.ps1 <carpeta>`, que falla si falta algo.

## La foto (`preview.png`)

- **Solo el visual**, con su título y subtítulo, sobre fondo blanco. Sin la interfaz de Power BI Desktop.
- **A 2x**: 1200 px de ancho como mínimo (el check lo exige). PNG o WebP.
- Datos del modelo maestro Contoso-Retail, nunca de un cliente. Sin logos ni fotos de personas.

**Cómo se saca:** la medida HTML se dibuja sola, sin Desktop: se evalúa sobre el PBIP con la página filtrada como en el informe y su HTML se fotografía en un navegador sin interfaz a 2x (`deviceScaleFactor: 2`), recortado al visual. Si no se puede, `pbi-captura.ps1` del PBIP abierto y recorte exacto a la posición del visual en su `visual.json`.

## La tarjeta de la galería (`card.png`)

La foto encajada en un lienzo blanco de 1600×900 (16:9), para que todas las celdas de la galería midan igual. Se genera desde `preview.png` con sharp: recorte del blanco sobrante, `fit: contain` en 1520×820 y 40 px de margen.

## La carpeta

`Nombre_Con_Guiones_Bajos/` con `README.md`, `Nombre_Con_Guiones_Bajos.zip`, la pieza suelta (`<slug>.dax`) y `pbip/Nombre_Con_Guiones_Bajos.pbip`.