class Personaje {
  var property monedas = 100
  const valorBase = 3
  var property valorBaseLucha = 1 
  var property hechizoPreferido = hechizoBasico

  const property artefactos = #{}
  const capacidadDeCarga = 200

  method nivelHechiceria() = 
    (valorBase * hechizoPreferido.poder()) + fuerzaOscura.valor()

  method seCreePoderoso() = hechizoPreferido.esPoderoso()

  method habilidadLucha() = valorBaseLucha + artefactos.sum{ artefacto => artefacto.unidadesDeLucha(self)}

  method agregarArtefacto(artefacto){ 
    if(capacidadDeCarga < self.pesoArtefactos() + artefacto.peso(self)) throw new Exception(message = "Capacidad de carga excedida")
    else artefactos.add(artefacto) }

  method pesoArtefactos() = artefactos.sum{ artefacto => artefacto.peso(self) }

  method removerArtefacto(artefacto){ artefactos.remove(artefacto) }

  method habLuchaMayorANvlHechiceria() = self.habilidadLucha() > self.nivelHechiceria()

  method mejorArtefacto() = artefactos.filter({ artefacto => artefacto != espejoFantastico}).max{ artefacto => artefacto.unidadesDeLucha(self) }

  method soloContieneEspejo() = artefactos == #{espejoFantastico}

  method estaCargado() = artefactos.size() >= 5

  method canjearHechizoPreferidoPor(hechizo){
    if(feriaDeHechiceria.puedeCostearHechizo(hechizo, self)){
      monedas = monedas - (hechizo.precio(self) - hechizoPreferido.precio(self) / 2).max(0)
      hechizoPreferido = hechizo //el hechizo obtenido para a ser el preferido
    } else throw new Exception(message = "No se puede costear Hechizo")
  }
  /* Como se toma como parte de precio la mitad del preferido, entonces primero debo ver si eso cubre el costo, osea si 
    hechizoPreferido.precio(self)/2 >= hechizo.precio(self) ya lo cubre, por lo que mis monedas no disminuyen, pero si fuera
    hechizoPreferido.precio(self)/2 < hechizo.precio(self) entonces las monedas disminuirian hechizo.precio(self)-hechizoPreferido.precio(self)/2
    pero para no usar un if, voy a hacerlo con "max", con esto me aseguro que la resta sea positiva, osea que
    0 < hechizo.precio(self)-hechizoPreferido.precio(self)/2 */

  method comprarArtefacto(artefacto){
    if(feriaDeHechiceria.puedeCostearArtefacto(artefacto, self)) {
      artefactos.add(artefacto)
      monedas = monedas - artefacto.precio(self)
    } else throw new Exception(message = "No se puede costear Artefacto")
  }

  method cumplirObjetivo(){
    monedas += 10
    return true
  }

  method comprarArtefactoAComerciante(comerciante,artefacto){
    self.agregarArtefacto(artefacto)
    monedas = monedas - (artefacto.precio(self) + comerciante.impuestoASumar(artefacto.precio(self)))
  }
}

object hechizoBasico { //es un hechizo
  method poder() = 10
  method esPoderoso() = false
  method precio(guerrero) = 10
}

object fuerzaOscura {
  var property valor = 5
}

object eclipse {
  method eclipsar(){
    fuerzaOscura.valor(fuerzaOscura.valor() * 2)
  }
}

class LibroDeHechizos {
  const property hechizos
  method poder() = hechizos.filter{ h => h.esPoderoso() }.sum{ hechizoPoderoso => hechizoPoderoso.poder() }
  method esPoderoso() = hechizos.any{ hechizo => hechizo.esPoderoso() }
  method precio(guerrero) = hechizos.size() * 10 + hechizos.sum{ h => if(h.esPoderoso()) h.poder() else 0 }
}

class HechizoLogos { //es un hechizo
  var property nombre
  var property factor
  method poder() = nombre.size() * factor
  method esPoderoso() = self.poder() > 15
  method precio(guerrero) = self.poder()
  method peso() = 0
}

object espectroMalefico inherits HechizoLogos (nombre = "espectro malefico",factor=1){ //es un hechizo logos
}

object feriaDeHechiceria {
  method puedeCostearHechizo(hechizo,personaje) = 
    personaje.monedas() + personaje.hechizoPreferido().precio(personaje) > hechizo.precio(personaje)
  method puedeCostearArtefacto(artefacto, personaje) = personaje.monedas() > artefacto.precio(personaje)
}

/////////////////////////////////////////
///////////////////////////////////////// ENTREGA 3

///////////////////////////////////////// 1

object hechizoComercial inherits HechizoLogos (nombre = "el hechizo comercial",factor = 0.20){
  var property multiplicador = 2
  override method poder() = nombre.size() * factor * multiplicador
}

///////////////////////////////////////// 2

class Artefacto{
  const peso = 0
  const fechaCompra = new Date()

  method unidadesDeLucha(guerrero)
  method precio(guerrero)
  method peso(guerrero) = peso - self.factorDeCorreccion().min(1)
  method factorDeCorreccion() = self.diasDesdeCompra() / 1000
  method diasDesdeCompra() = new Date() - fechaCompra
}

class CollarDivino inherits Artefacto{
  var property perlas = 5
  
  override method peso(guerrero) = super(guerrero) + perlas * 0.5
  override method unidadesDeLucha(guerrero) = perlas
  override method precio(guerrero) = perlas * 2
}

object espejoFantastico inherits Artefacto(){
  override method unidadesDeLucha(guerrero) = 
    if (guerrero.soloContieneEspejo()) 0
    else guerrero.mejorArtefacto().unidadesDeLucha(guerrero)
  override method precio(guerrero) = 90
}

class Arma inherits Artefacto{ //hacha, lanza, espada
  override method unidadesDeLucha(guerrero) = 3
  override method precio(guerrero) = self.peso(guerrero) * 5 //debido a este metodo, tuve que pasar como argumento "guerrero a todos los precios"
}

class MascaraOscura inherits Artefacto{
  const indiceOscuridad
  var property poderMinimo = 4

  override method peso(guerrero) = super(guerrero) + (self.unidadesDeLucha(guerrero) - 3).max(0)
  override method unidadesDeLucha(guerrero) = ( (fuerzaOscura.valor()/2) * indiceOscuridad.max(0).min(1) ).max(poderMinimo)
  override method precio(guerrero) = 10 * indiceOscuridad
}

class Armadura inherits Artefacto{
  var property refuerzo
  const property valorBase = 2
  override method peso(guerrero) = super(guerrero) + refuerzo.peso()
  override method unidadesDeLucha(guerrero) = valorBase + refuerzo.unidadesDeLucha(guerrero)
  override method precio(guerrero) = refuerzo.precio(self)
}

///////////////////////////////Refuerzos (abajo)     PODRIA HACER UNA CLASE
class CotaDeMalla {
  const unidadesDeLucha = 1
  method peso() = 1
  method unidadesDeLucha(guerrero) = unidadesDeLucha
  method precio(armadura) = unidadesDeLucha / 2
}
object bendicion {
  method peso() = 0
  method unidadesDeLucha(guerrero) = guerrero.nivelHechiceria()
  method precio(armadura) = armadura.valorBase()
}
class Hechizo {
  var property tipo //malefico o basico
  method peso() = if(tipo.poder().even()) 2 else 1 
  method unidadesDeLucha(guerrero) = tipo.poder()
  method precio(armadura) = armadura.valorBase() + tipo.precio()
}
object ningunRefuerzo {
  method peso() = 0
  method unidadesDeLucha(guerrero) = 0
  method precio(armadura) = 2
}
///////////////////////////////Refuerzos (arriba)

///////////////////////////////////////// 3

class NPC inherits Personaje{
  var property dificultad
  override method habilidadLucha() = super() * dificultad.factor()
}

object facil{
  method factor() = 1
}
object moderado{
  method factor() = 2
}
object dificil{
  method factor() = 4
}

///////////////////////////////////////// 4

class Comerciante{
  var property tipo
  method impuestoASumar(precio) = tipo.impuestoASumar(precio)
}
class ComercianteIndependiente{
  const property id = "Ind"
  var property comision
  method impuestoASumar(precio) = precio * comision
}
class ComercianteRegistrado{
  const property id = "Reg"
  const comision = 0.21
  method impuestoASumar(precio) = precio * comision
}
class ComercianteConImpuesto{
  const property id = "Imp"
  var property importeMinimoNoImponible
  method impuestoASumar(precio) = 
    if(precio<importeMinimoNoImponible) 0 else (precio-importeMinimoNoImponible) * 0.35 
}
object recategorizador {
  method recategorizar(comerciante) {
    if(comerciante.tipo().id()=="Ind"){
      if((comerciante.tipo().comision())*2 > 0.21){
        comerciante.tipo(new ComercianteRegistrado())
      }
      else {comerciante.tipo().comision( (comerciante.tipo().comision())*2 )}
    }
    else if(comerciante.tipo().id()=="Reg"){
      comerciante.tipo(new ComercianteConImpuesto(importeMinimoNoImponible=5))
    }
  }
}