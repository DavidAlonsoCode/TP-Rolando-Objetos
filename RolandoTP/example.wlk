/////////////////////////////////////////// 1
/* los instancio de la clase Personaje (entrega 2)
object rolando {
  const valorBase = 3
  var property valorBaseLucha = 1 
  var property hechizoPreferido = espectroMalefico
  const hechizos = [espectroMalefico, hechizoBasico]
  const artefactos = #{espadaDelDestino,collarDivino,mascaraOscura}

  method nivelHechiceria() = 
    (valorBase * hechizoPreferido.poder()) + fuerzaOscura.valor()

  method seCreePoderoso() = hechizoPreferido.esPoderoso()

  method habilidadLucha() = valorBaseLucha + artefactos.sum{ artefacto => artefacto.unidadesDeLucha(self)}

  method agregarArtefacto(artefacto){ artefactos.add(artefacto) }
  method removerArtefacto(artefacto){ artefactos.remove(artefacto) }

  method habLuchaMayorANvlHechiceria() = self.habilidadLucha() > self.nivelHechiceria()

  method mejorArtefacto() = artefactos.filter({ artefacto => artefacto != espejoFantastico}).max{ artefacto => artefacto.unidadesDeLucha(self) }

  method soloContieneEspejo() = artefactos == #{espejoFantastico}

  method estaCargado() = artefactos.size() >= 5
}
*/

//hechizo malefico lo hice una instancia de clase Logos (entrega 2)

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

/////////////////////////////////////////// 2

object espadaDelDestino{
  method unidadesDeLucha(guerrero) = 3
}
object collarDivino{
  var property perlas = 5
  method unidadesDeLucha(guerrero) = perlas
  method precio(guerrero) = perlas * 2
}
/*
object mascaraOscura{
  method unidadesDeLucha(guerrero) = (fuerzaOscura.valor()/2).max(4) 
}
*/
/////////////////////////////////////////// 3

/* MODIFICO POR ENTREGA 2
class Armadura {
  var property refuerzo = ningunRefuerzo 
  method unidadesDeLucha(guerrero) = 2 + refuerzo.valor(guerrero)
}
//Refuerzos (abajo)
object cotaDeMalla {
  method valor(guerrero) = 1
}
object bendicion {
  method valor(guerrero) = guerrero.nivelHechiceria()
}
class Hechizo { //revisar
  var property tipo 
  method valor(guerrero) = tipo.poder()
}
object ningunRefuerzo {
  method valor(guerrero) = 0
}
//Refuerzos (arriba)
*/

object espejoFantastico {
  method unidadesDeLucha(guerrero) = 
    if (guerrero.soloContieneEspejo()) 0
    else guerrero.mejorArtefacto().unidadesDeLucha(guerrero)
  method precio(guerrero) = 90
}

class LibroDeHechizos {
  const property hechizos
  method poder() = hechizos.filter{ h => h.esPoderoso() }.sum{ hechizoPoderoso => hechizoPoderoso.poder() }
  method esPoderoso() = hechizos.any{ hechizo => hechizo.esPoderoso() }
  method precio(guerrero) = hechizos.size() * 10 + hechizos.sum{ h => if(h.esPoderoso()) h.poder() else 0 }
}

/////////////////////////////////////////
///////////////////////////////////////// ENTREGA 2

///////////////////////////////////////// 1

class Personaje {
  var property monedas = 100
  const valorBase = 3
  var property valorBaseLucha = 1 
  var property hechizoPreferido = hechizoBasico
  const hechizos
  const property artefactos

  method nivelHechiceria() = 
    (valorBase * hechizoPreferido.poder()) + fuerzaOscura.valor()

  method seCreePoderoso() = hechizoPreferido.esPoderoso()

  method habilidadLucha() = valorBaseLucha + artefactos.sum{ artefacto => artefacto.unidadesDeLucha(self)}

  method agregarArtefacto(artefacto){ artefactos.add(artefacto) }
  method removerArtefacto(artefacto){ artefactos.remove(artefacto) }

  method habLuchaMayorANvlHechiceria() = self.habilidadLucha() > self.nivelHechiceria()

  method mejorArtefacto() = artefactos.filter({ artefacto => artefacto != espejoFantastico}).max{ artefacto => artefacto.unidadesDeLucha(self) }

  method soloContieneEspejo() = artefactos == #{espejoFantastico}

  method estaCargado() = artefactos.size() >= 5

  method canjearHechizoPreferidoPor(hechizo){
    if(feriaDeHechiceria.puedeCostearHechizo(hechizo, self)){
      hechizos.add(hechizo) //se agrega a la lista de hechizos (aunque creo que la modele al pedo porque nunca la uso)
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

}

class HechizoLogos { //es un hechizo
  var property nombre
  const factor
  method poder() = nombre.size() * factor
  method esPoderoso() = nombre.size() > 15
  method precio(guerrero) = self.poder()
}

object espectroMalefico inherits HechizoLogos (nombre = "espectro malefico",factor=1){ //es un hechizo logos
}

///////////////////////////////////////// 2

class Arma{ //hacha, lanza, espada
  method unidadesDeLucha(guerrero) = 3
  method precio(guerrero) = self.unidadesDeLucha(guerrero) * 5 //debido a este metodo, tuve que pasar como argumento "guerrero a todos los precios"
}

class MascaraOscura{
  const indiceOscuridad
  var property poderMinimo = 4
  method unidadesDeLucha(guerrero) = ( (fuerzaOscura.valor()/2) * indiceOscuridad.max(0).min(1) ).max(poderMinimo)
  method precio(guerrero) = 70 + fuerzaOscura.valor() * indiceOscuridad
}

///////////////////////////////////////// 3
  
class Armadura{
  var property refuerzo
  const property valorBase = 2
  method unidadesDeLucha(guerrero) = valorBase + refuerzo.unidadesDeLucha(guerrero)
  method precio(guerrero) = refuerzo.precio(self)
}

//Refuerzos (abajo)
class CotaDeMalla {
  const unidadesDeLucha = 1
  method unidadesDeLucha(guerrero) = unidadesDeLucha
  method precio(armadura) = unidadesDeLucha / 2
}
object bendicion {
  method unidadesDeLucha(guerrero) = guerrero.nivelHechiceria()
  method precio(armadura) = armadura.valorBase()
}
class Hechizo {
  var property tipo //malefico o basico 
  method unidadesDeLucha(guerrero) = tipo.poder()
  method precio(armadura) = armadura.valorBase() + tipo.precio()
}
object ningunRefuerzo {
  method unidadesDeLucha(guerrero) = 0
  method precio(armadura) = 2
}
//Refuerzos (arriba)

object feriaDeHechiceria {
  method puedeCostearHechizo(hechizo,personaje) = 
    personaje.monedas() + personaje.hechizoPreferido().precio(personaje) > hechizo.precio(personaje)
  method puedeCostearArtefacto(artefacto, personaje) = personaje.monedas() > artefacto.precio(personaje)
}