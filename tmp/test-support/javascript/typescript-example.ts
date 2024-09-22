interface Person {
    name: string;
    age: number;
}

function createGreeting(person: Person): string {
    let greeting = `Hello, ${person.name}!`;

    if (person.age < 18) {
        greeting += " You're still a minor.";
    } else if (person.age >= 18 && person.age < 65) {
        greeting += " You're an adult.";
    } else {
        greeting += " You're a senior citizen.";
    }

    return greeting;
}

const alice: Person = { name: 'Alice', age: 30 };
const bob: Person = { name: 'Bob', age: 17 };
const charlie: Person = { name: 'Charlie', age: 70 };

console.log(createGreeting(alice));
console.log(createGreeting(bob));
console.log(createGreeting(charlie));