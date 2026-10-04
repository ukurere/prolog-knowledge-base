:- encoding(utf8).

/*
    Лабораторна робота 1. Подання знань і бази знань на Пролозі
    Предметна область: "Тварини"

    Базу знань побудовано на основі експертної системи визначення тварини
    (тигр, тхір, тюлень, тапір, тарпан, тукан, тетерук, тунець, тарантул, терміт):
    ті самі тварини та ознаки (клас, живлення, середовище, смуги, дзьоб)
    подано тут як онтологію: класи, екземпляри, атрибути та зв'язки.
*/

% =====================================================================
% КЛАСИ
% =====================================================================

class(animal).
class(chordate).
class(arthropod).
class(mammal).
class(bird).
class(fish).
class(insect).
class(arachnid).

class(habitat).
class(terrestrial_habitat).
class(aquatic_habitat).

% =====================================================================
% ІЄРАРХІЯ КЛАСІВ (ієрархічні зв'язки, is-a між класами)
% =====================================================================

subclass(chordate,  animal).
subclass(arthropod, animal).

subclass(mammal,    chordate).
subclass(bird,      chordate).
subclass(fish,      chordate).

subclass(insect,    arthropod).
subclass(arachnid,  arthropod).

subclass(terrestrial_habitat, habitat).
subclass(aquatic_habitat,     habitat).

% =====================================================================
% ЕКЗЕМПЛЯРИ КЛАСІВ (instance-of)
% =====================================================================

instance_of(tiger,        mammal).
instance_of(polecat,      mammal).
instance_of(seal,         mammal).
instance_of(tapir,        mammal).
instance_of(tarpan,       mammal).

instance_of(toucan,       bird).
instance_of(black_grouse, bird).

instance_of(tuna,         fish).
instance_of(cod,          fish).

instance_of(tarantula,    arachnid).
instance_of(termite,      insect).

instance_of(forest,       terrestrial_habitat).
instance_of(steppe,       terrestrial_habitat).
instance_of(tropics,      terrestrial_habitat).
instance_of(sea,          aquatic_habitat).

% =====================================================================
% АТРИБУТИ ЕКЗЕМПЛЯРІВ: has_attribute(Об'єкт, Атрибут, Значення)
% =====================================================================

has_attribute(tiger,        diet, carnivore).
has_attribute(polecat,      diet, carnivore).
has_attribute(seal,         diet, carnivore).
has_attribute(tapir,        diet, herbivore).
has_attribute(tarpan,       diet, herbivore).
has_attribute(toucan,       diet, omnivore).
has_attribute(black_grouse, diet, herbivore).
has_attribute(tuna,         diet, carnivore).
has_attribute(cod,          diet, carnivore).
has_attribute(tarantula,    diet, carnivore).
has_attribute(termite,      diet, herbivore).

has_attribute(tiger,        stripes, yes).
has_attribute(polecat,      stripes, no).
has_attribute(toucan,       bright_beak, yes).
has_attribute(black_grouse, bright_beak, no).

has_attribute(tarpan,       status, extinct).

% Виняток з успадкування: тюлень - ссавець, але пересувається плаваючи
has_attribute(seal,         locomotion, swimming).

% =====================================================================
% АТРИБУТИ КЛАСІВ (успадковуються всіма екземплярами та підкласами)
% =====================================================================

class_attribute(animal,    status,     extant).
class_attribute(chordate,  skeleton,   internal).
class_attribute(arthropod, skeleton,   external).
class_attribute(mammal,    body_cover, fur).
class_attribute(mammal,    locomotion, walking).
class_attribute(bird,      body_cover, feathers).
class_attribute(bird,      locomotion, flight).
class_attribute(fish,      body_cover, scales).
class_attribute(fish,      locomotion, swimming).
class_attribute(insect,    legs,       6).
class_attribute(arachnid,  legs,       8).

% =====================================================================
% АСОЦІАТИВНІ ЗВ'ЯЗКИ
% =====================================================================

% lives_in(Тварина, Середовище) - основне середовище існування
lives_in(tiger,        forest).
lives_in(polecat,      forest).
lives_in(black_grouse, forest).
lives_in(tarpan,       steppe).
lives_in(tapir,        tropics).
lives_in(toucan,       tropics).
lives_in(tarantula,    tropics).
lives_in(termite,      tropics).
lives_in(seal,         sea).
lives_in(tuna,         sea).
lives_in(cod,          sea).

% eats(Хто, Кого) - харчовий зв'язок між тваринами
eats(tiger,     tapir).
eats(polecat,   black_grouse).
eats(seal,      cod).
eats(tuna,      cod).
eats(toucan,    tarantula).
eats(tarantula, termite).

% =====================================================================
% НЕСУМІСНІ КЛАСИ
% =====================================================================

disjoint(chordate, arthropod).
disjoint(mammal,   bird).
disjoint(mammal,   fish).
disjoint(bird,     fish).
disjoint(insect,   arachnid).
disjoint(animal,   habitat).
disjoint(terrestrial_habitat, aquatic_habitat).

% =====================================================================
% ПРАВИЛА
% =====================================================================

% Транзитивне замикання ієрархії класів.
% Список Visited захищає від зациклення, якщо в ієрархії з'явиться цикл.
subclass_of(Sub, Super) :-
    subclass_of(Sub, Super, [Sub]).

subclass_of(Sub, Super, _) :-
    subclass(Sub, Super).
subclass_of(Sub, Super, Visited) :-
    subclass(Sub, Mid),
    \+ member(Mid, Visited),
    subclass_of(Mid, Super, [Mid | Visited]).

% Успадкування належності до класу
is_a(Object, Class) :-
    instance_of(Object, Class).
is_a(Object, Super) :-
    instance_of(Object, Class),
    subclass_of(Class, Super).

% Значення атрибута з урахуванням успадкування та винятків:
% власний атрибут екземпляра має пріоритет над атрибутом класу,
% атрибут найближчого класу - над атрибутом надкласу.
attribute_key(Key) :-
    setof(K, O^V^( has_attribute(O, K, V) ; class_attribute(O, K, V) ), Keys),
    member(Key, Keys).

value(Object, Attr, Value) :-
    instance_of(Object, Class),
    attribute_key(Attr),
    (   has_attribute(Object, Attr, Own)
    ->  Value = Own
    ;   class_value(Class, Attr, Value)
    ).

class_value(Class, Attr, Value) :-
    (   class_attribute(Class, Attr, V)
    ->  Value = V
    ;   subclass(Class, Super),
        class_value(Super, Attr, Value)
    ).

% Біологічний клас тварини (рівень одразу під типом)
animal_class(Animal, Class) :-
    is_a(Animal, Class),
    subclass(Class, Type),
    subclass(Type, animal).

predator(Animal) :-
    is_a(Animal, animal),
    has_attribute(Animal, diet, carnivore).

% Харчовий ланцюг: Animal прямо або опосередковано живиться Prey.
% Рекурсія з пам'яттю відвіданих вершин (захист від циклів у eats/2).
food_chain(Animal, Prey) :-
    food_chain(Animal, Prey, [Animal]).

food_chain(Animal, Prey, _) :-
    eats(Animal, Prey).
food_chain(Animal, Prey, Visited) :-
    eats(Animal, Mid),
    \+ member(Mid, Visited),
    food_chain(Mid, Prey, [Mid | Visited]).

% Верхівковий хижак: когось їсть, але сам ні для кого не є їжею
top_predator(Animal) :-
    eats(Animal, _),
    \+ eats(_, Animal).

% Тварини, що мешкають в одному середовищі
neighbours(A, B, Habitat) :-
    lives_in(A, Habitat),
    lives_in(B, Habitat),
    A @< B.

% Конкуренти: різні тварини, що полюють на ту саму здобич
competitors(A, B, Prey) :-
    eats(A, Prey),
    eats(B, Prey),
    A @< B.

aquatic_animal(Animal) :-
    lives_in(Animal, Habitat),
    is_a(Habitat, aquatic_habitat).

% Пошук тварини за ознаками - декларативний аналог identify/1
% з експертної системи (без діалогу з користувачем)
candidate(Animal, Class, Diet, Habitat) :-
    animal_class(Animal, Class),
    has_attribute(Animal, diet, Diet),
    lives_in(Animal, Habitat).

% =====================================================================
% ПЕРЕВІРКА УЗГОДЖЕНОСТІ
% =====================================================================

disjoint_classes(A, B) :- disjoint(A, B).
disjoint_classes(A, B) :- disjoint(B, A).

% 1. Об'єкт належить до двох несумісних класів
conflicting_types(Object, C1, C2) :-
    is_a(Object, C1),
    is_a(Object, C2),
    C1 @< C2,
    disjoint_classes(C1, C2).

% 2. Використано невідомий клас
unknown_class(Object, Class) :-
    instance_of(Object, Class),
    \+ class(Class).
unknown_class(Sub, Super) :-
    subclass(Sub, Super),
    ( \+ class(Sub) ; \+ class(Super) ).

% 3. Цикл в ієрархії класів
hierarchy_cycle(Class) :-
    class(Class),
    subclass_of(Class, Class).

% 4. Неправильні типи аргументів відношень
invalid_relation(eats(A, B)) :-
    eats(A, B),
    ( \+ is_a(A, animal) ; \+ is_a(B, animal) ).
invalid_relation(lives_in(A, H)) :-
    lives_in(A, H),
    ( \+ is_a(A, animal) ; \+ is_a(H, habitat) ).

% 5. Травоїдна тварина в базі поїдає іншу тварину
diet_contradiction(Animal, Prey) :-
    eats(Animal, Prey),
    has_attribute(Animal, diet, herbivore).

% 6. Цикл у харчовому ланцюгу (A прямо чи опосередковано їсть сама себе)
food_cycle(Animal) :-
    is_a(Animal, animal),
    food_chain(Animal, Animal).

% 7. Риба записана як мешканець наземного середовища
habitat_mismatch(Animal, Habitat) :-
    lives_in(Animal, Habitat),
    is_a(Animal, fish),
    is_a(Habitat, terrestrial_habitat).

model_issue(conflicting_types(O, C1, C2)) :- conflicting_types(O, C1, C2).
model_issue(unknown_class(A, B))          :- unknown_class(A, B).
model_issue(hierarchy_cycle(C))           :- hierarchy_cycle(C).
model_issue(invalid_relation(R))          :- invalid_relation(R).
model_issue(diet_contradiction(A, B))     :- diet_contradiction(A, B).
model_issue(food_cycle(A))                :- food_cycle(A).
model_issue(habitat_mismatch(A, H))       :- habitat_mismatch(A, H).

% =====================================================================
% ПРИКЛАДИ ЗАПИТІВ
% =====================================================================

% ?- is_a(tiger, chordate).
% ?- is_a(termite, animal).
% ?- setof(A, is_a(A, mammal), L).
% ?- value(tiger, body_cover, V).
% ?- value(seal, locomotion, V).
% ?- value(tarpan, status, V).
% ?- value(tapir, status, V).
% ?- value(tarantula, legs, N).
% ?- value(tarantula, skeleton, S).
% ?- setof(P, food_chain(toucan, P), L).
% ?- top_predator(A).
% ?- competitors(A, B, Prey).
% ?- neighbours(A, B, forest).
% ?- aquatic_animal(A).
% ?- candidate(A, mammal, carnivore, forest), has_attribute(A, stripes, yes).
% ?- model_issue(Issue).
