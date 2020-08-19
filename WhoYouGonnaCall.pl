
%herrameintasRequeridas(Tarea, ListaHerramientas).
herramientasRequeridas(ordenarCuarto, [aspiradora(100), trapeador, plumero]).
%herramientasRequeridas(ordenarCuarto, [escoba, trapeador, plumero]).
%pidiendolo así, queda como que ordenar cuarto necesita TODAS esas herramientas, y no entiende que es una u otra.
%lo cual modificaría la funcionalidad de mi programa
herramientasRequeridas(limpiarTecho, [escoba, pala]).
herramientasRequeridas(cortarPasto, [bordedadora]).
herramientasRequeridas(limpiarBanio, [sopapa, trapeador]).
herramientasRequeridas(encerarPisos, [lustradpesora, cera, aspiradora(300)]).

tareaPedida(ana, limpiarBanio, 40).
tareaPedida(luis, ordenarCuarto, 30).

precio(ordenarCuarto, 10).
precio(limpiarTecho, 20).
precio(cortarPasto, 5).
precio(limpiarBanio, 2).
precio(encerarPisos, 4).

/*Agregar a la base de conocimientos la siguiente información:
Egon tiene una aspiradora de 200 de potencia.
Egon y Peter tienen un trapeador, Ray y Winston no.
Sólo Winston tiene una varita de neutrones.
Nadie tiene una bordeadora.
*/
%tiene(Persona, Herramienta).

tiene(egon, aspiradora(200)).
tiene(egon, trapeador).
tiene(egon, plumero).
tiene(egon, sopapa).
tiene(peter, trapeador).
tiene(peter, sopapa).
tiene(wiston, varitaDeNeutrones).

/*Definir un predicado que determine si un integrante satisface la necesidad de una herramienta requerida. 
Esto será cierto si tiene dicha herramienta, teniendo en cuenta que si la herramienta requerida es una aspiradora, 
el integrante debe tener una con potencia igual o superior a la requerida.
Nota: No se pretende que sea inversible respecto a la herramienta requerida.*/

tieneHerramientaRequerida(Persona, Herramienta):-
    tiene(Persona, Herramienta),
    Herramienta \= aspiradora(_).

tieneHerramientaRequerida(Persona, aspiradora(Potencia)):-
    tiene(Persona, aspiradora(OtraPotencia)),
    OtraPotencia >= Potencia.

tieneHerramientaRequerida(Persona, ListaHerramientasReemplazables):-
    member(Herramienta, ListaHerramientasReemplazables),
    tieneHerramientaRequerida(Persona, Herramienta)).
    
/*Queremos saber si una persona puede realizar una tarea, que dependerá de las herramientas que tenga. Sabemos que:
- Quien tenga una varita de neutrones puede hacer cualquier tarea, independientemente de qué herramientas requiera dicha tarea.
- Alternativamente alguien puede hacer una tarea si puede satisfacer la necesidad de todas las herramientas requeridas para dicha tarea.*/

puedeRealizarTarea(Persona, Tarea):-
    tiene(Persona, varitaDeNeutrones),
    herramientasRequeridas(Tarea, _).

puedeRealizarTarea(Persona, Tarea):-
    herramientasRequeridas(Tarea, Herramientas),
    tieneTodasLasHerramientas(Persona, Herramientas).

/*puedeRealizarTarea(Persona, Tarea):-
    tiene(Persona, _),
    forall((Tarea, [Herramienta]), tieneHerramientaRequerida(Persona, Herramienta)).

herramientaNecesaria([Herramienta|DemasHerramientas], Herramienta):-
    herramientaNecesaria(DemasHerramientas).

herramientaNecesaria([_], _).*/

%Caso Base        
tieneTodasLasHerramientas(Persona, [Herramienta]):-
    tieneHerramientaRequerida(Persona, Herramienta).

%Caso Recursivo
tieneTodasLasHerramientas(Persona, [PrimeraHerramienta|DemasHerramientas]):-
     tieneHerramientaRequerida(Persona, PrimeraHerramienta),
     tieneTodasLasHerramientas(Persona, DemasHerramientas).


    
/*Nos interesa saber de antemano cuanto se le debería cobrar a un cliente por un pedido (que son las tareas que pide). 
Para ellos disponemos de la siguiente información en la base de conocimientos:
- tareaPedida/3: relaciona al cliente, con la tarea pedida y la cantidad de metros cuadrados sobre los cuales hay que realizar esa tarea.
- precio/2: relaciona una tarea con el precio por metro cuadrado que se cobraría al cliente.
Entonces lo que se le cobraría al cliente sería la suma del valor a cobrar por cada tarea, multiplicando el precio por 
los metros cuadrados de la tarea.
*/


cuantoCobrar(Cliente, PrecioACobrar):-
    tareaPedida(Cliente, _,_), %lo agregamos para que el cliente pueda ser inversible y así el predicado sea totalmente inversible
    findall(Costo, costoTarea(Cliente, _, Costo), ListaCostos),
    sum_list(ListaCostos, PrecioACobrar).
    
costoTarea(Cliente, Tarea, Costo):-
    tareaPedida(Cliente, Tarea, MetrosCuadrados),
    precio(Tarea, Precio),
    Costo is Precio * MetrosCuadrados.

/*Finalmente necesitamos saber quiénes aceptarían el pedido de un cliente. Un integrante acepta el pedido cuando puede 
realizar todas las tareas del pedido y además está dispuesto a aceptarlo.
Sabemos que Ray sólo acepta pedidos que no incluyan limpiar techos, Winston sólo acepta pedidos que paguen más de $500, 
Egon está dispuesto a aceptar pedidos que no tengan tareas complejas y Peter está dispuesto a aceptar cualquier pedido.
Decimos que una tarea es compleja si requiere más de dos herramientas. Además la limpieza de techos siempre es compleja.*/

aceptaPedido(Persona, Cliente):-
    tareaPedida(Cliente, _,_), %inversible para Cliente
    tiene(Persona, _), %inversible para la persona
    forall(tareaPedida(Cliente, Tarea, _), (puedeRealizarTarea(Persona, Tarea), estaDispuestoAHacer(Persona, Tarea))).

estaDispuestoAHacer(ray, Tarea):-
    Tarea \= limpiarTecho.

estaDispuestoAHacer(wiston, Tarea):-
    costoTarea(_, Tarea, Costo),
    Costo > 500.

estaDispuestoAHacer(peter, _).

estaDispuestoAHacer(egon, Tarea):-
    tareaPedida(_, Tarea, _), %lo utilizamos para ligar Tarea y pueda ser inversible
    not(tareaCompleja(Tarea)).

tareaCompleja(limpiarTecho).

tareaCompleja(Tarea):-
    herramientasRequeridas(Tarea, ListaHerramientas),
    length(ListaHerramientas, TotalDeHerramientas),
    TotalDeHerramientas > 2.


    








