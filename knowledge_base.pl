:- encoding(utf8).

/*
    Лабораторна робота 1. Подання знань і бази знань на Пролозі
    Предметна область: "Тварини" (усі тварини в базі мають назву на літеру "Т")

    Базу знань побудовано на основі експертної системи визначення тварини:
    ті самі тварини та ознаки (клас, живлення, середовище, смуги, дзьоб)
    подано тут як онтологію: класи, екземпляри, атрибути та зв'язки.
*/

% =====================================================================
% КЛАСИ
% =====================================================================

class(тварина).
class(хордові).
class(членистоногі).
class(ссавець).
class(птах).
class(риба).
class(комаха).
class(павукоподібний).

class(середовище).
class(наземне_середовище).
class(водне_середовище).

% =====================================================================
% ІЄРАРХІЯ КЛАСІВ (ієрархічні зв'язки, is-a між класами)
% =====================================================================

subclass(хордові,        тварина).
subclass(членистоногі,   тварина).

subclass(ссавець,        хордові).
subclass(птах,           хордові).
subclass(риба,           хордові).

subclass(комаха,         членистоногі).
subclass(павукоподібний, членистоногі).

subclass(наземне_середовище, середовище).
subclass(водне_середовище,   середовище).

% =====================================================================
% ЕКЗЕМПЛЯРИ КЛАСІВ (instance-of)
% =====================================================================

instance_of(тигр,     ссавець).
instance_of(тхір,     ссавець).
instance_of(тюлень,   ссавець).
instance_of(тапір,    ссавець).
instance_of(тарпан,   ссавець).

instance_of(тукан,    птах).
instance_of(тетерук,  птах).

instance_of(тунець,   риба).
instance_of(тріска,   риба).

instance_of(тарантул, павукоподібний).
instance_of(терміт,   комаха).

instance_of(ліс,      наземне_середовище).
instance_of(степ,     наземне_середовище).
instance_of(тропіки,  наземне_середовище).
instance_of(море,     водне_середовище).

% =====================================================================
% АТРИБУТИ ЕКЗЕМПЛЯРІВ: has_attribute(Об'єкт, Атрибут, Значення)
% =====================================================================

has_attribute(тигр,     живлення, хижак).
has_attribute(тхір,     живлення, хижак).
has_attribute(тюлень,   живлення, хижак).
has_attribute(тапір,    живлення, травоїдний).
has_attribute(тарпан,   живлення, травоїдний).
has_attribute(тукан,    живлення, всеїдний).
has_attribute(тетерук,  живлення, травоїдний).
has_attribute(тунець,   живлення, хижак).
has_attribute(тріска,   живлення, хижак).
has_attribute(тарантул, живлення, хижак).
has_attribute(терміт,   живлення, травоїдний).

has_attribute(тигр,     смуги, так).
has_attribute(тхір,     смуги, ні).
has_attribute(тукан,    яскравий_дзьоб, так).
has_attribute(тетерук,  яскравий_дзьоб, ні).

has_attribute(тарпан,   статус, вимерлий).

% Виняток з успадкування: тюлень - ссавець, але пересувається плаваючи
has_attribute(тюлень,   пересування, плавання).

% =====================================================================
% АТРИБУТИ КЛАСІВ (успадковуються всіма екземплярами та підкласами)
% =====================================================================

class_attribute(тварина,        статус,         існуючий).
class_attribute(хордові,        скелет,         внутрішній).
class_attribute(членистоногі,   скелет,         зовнішній).
class_attribute(ссавець,        покрив,         хутро).
class_attribute(ссавець,        пересування,    ходьба).
class_attribute(птах,           покрив,         оперення).
class_attribute(птах,           пересування,    політ).
class_attribute(риба,           покрив,         луска).
class_attribute(риба,           пересування,    плавання).
class_attribute(комаха,         кількість_ніг,  6).
class_attribute(павукоподібний, кількість_ніг,  8).

% =====================================================================
% АСОЦІАТИВНІ ЗВ'ЯЗКИ
% =====================================================================

% lives_in(Тварина, Середовище) - основне середовище існування
lives_in(тигр,     ліс).
lives_in(тхір,     ліс).
lives_in(тетерук,  ліс).
lives_in(тарпан,   степ).
lives_in(тапір,    тропіки).
lives_in(тукан,    тропіки).
lives_in(тарантул, тропіки).
lives_in(терміт,   тропіки).
lives_in(тюлень,   море).
lives_in(тунець,   море).
lives_in(тріска,   море).

% eats(Хто, Кого) - харчовий зв'язок між тваринами
eats(тигр,     тапір).
eats(тхір,     тетерук).
eats(тюлень,   тріска).
eats(тунець,   тріска).
eats(тукан,    тарантул).
eats(тарантул, терміт).

% =====================================================================
% НЕСУМІСНІ КЛАСИ
% =====================================================================

disjoint(хордові, членистоногі).
disjoint(ссавець, птах).
disjoint(ссавець, риба).
disjoint(птах,    риба).
disjoint(комаха,  павукоподібний).
disjoint(тварина, середовище).
disjoint(наземне_середовище, водне_середовище).

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
    subclass(Type, тварина).

predator(Animal) :-
    is_a(Animal, тварина),
    has_attribute(Animal, живлення, хижак).

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
    is_a(Habitat, водне_середовище).

% Пошук тварини за ознаками - декларативний аналог identify/1
% з експертної системи (без діалогу з користувачем)
candidate(Animal, Class, Diet, Habitat) :-
    animal_class(Animal, Class),
    has_attribute(Animal, живлення, Diet),
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
    ( \+ is_a(A, тварина) ; \+ is_a(B, тварина) ).
invalid_relation(lives_in(A, H)) :-
    lives_in(A, H),
    ( \+ is_a(A, тварина) ; \+ is_a(H, середовище) ).

% 5. Травоїдна тварина в базі поїдає іншу тварину
diet_contradiction(Animal, Prey) :-
    eats(Animal, Prey),
    has_attribute(Animal, живлення, травоїдний).

% 6. Цикл у харчовому ланцюгу (A прямо чи опосередковано їсть сама себе)
food_cycle(Animal) :-
    is_a(Animal, тварина),
    food_chain(Animal, Animal).

% 7. Риба записана як мешканець наземного середовища
habitat_mismatch(Animal, Habitat) :-
    lives_in(Animal, Habitat),
    is_a(Animal, риба),
    is_a(Habitat, наземне_середовище).

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

% ?- is_a(тигр, хордові).
% ?- is_a(терміт, тварина).
% ?- setof(A, is_a(A, ссавець), L).
% ?- value(тигр, покрив, V).
% ?- value(тюлень, пересування, V).
% ?- value(тарпан, статус, V).
% ?- value(тарантул, кількість_ніг, N).
% ?- setof(P, food_chain(тукан, P), L).
% ?- top_predator(A).
% ?- competitors(A, B, Prey).
% ?- neighbours(тигр, B, H).
% ?- candidate(A, ссавець, хижак, ліс), has_attribute(A, смуги, так).
% ?- model_issue(Issue).
