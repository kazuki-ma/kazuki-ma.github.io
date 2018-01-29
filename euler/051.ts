class Combinations {
    memo = {};
    get(n: number, k: number) : Uint32Array[] {
        const memo_label = n + 'C' + k;

        if (this.memo[memo_label]) {
            return this.memo[n + 'C' + k];
        }

        const list = [0, 1, 2];
        const ret: Uint32Array[] = [new Uint32Array(list)];
        while (list[0] != n - k) {
            for (let lastIdx = list.length - 1; true; lastIdx--) {
                list[lastIdx]++;
    
                if (list[lastIdx] >= n) {
                    continue;
                }
    
                for (;lastIdx <= list.length - 2; lastIdx++) {
                    list[lastIdx + 1] = list[lastIdx] + 1;
                }
    
                break;
            }
            ret.push(new Uint32Array(list));
        }
        return (this.memo[memo_label] = ret);
    }    
}

class Primes {
    primes: Uint32Array;

    constructor(max: number){
        this.primes = new Uint32Array(Math.sqrt(max));
    }
}

const primes = [2, 3, 5];
const targetPrimeRegex = new RegExp([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(i => `${i}.*?${i}.*?${i}.`).join("|"))
const map = {};

map.pushResult = function (key, value) {
    if (!map[key]) {
        map[key] = [];
    }
    return map[key].push(value);
};

for (let i = 6; i < 1000000; i += 6) {
    [1,5].forEach(offset => {
        if (i < 10000 || targetPrimeRegex.test((i + offset).toString())) {
            tryPrime(i + offset);
        }
    });
}

const matchPrimes = primes.filter(i => targetPrimeRegex.test(i.toString()));
const combinations = new Combinations();

matchPrimes.forEach((p: number) => {
    const exec = targetPrimeRegex.exec(p.toString());
    const x = exec[0][0];
    let splited = p.toString().split(x);

    if (splited[splited.length - 1] === '') {
        splited.pop();
        splited[splited.length - 1] += x;
    }

    const cSet = combinations.get(splited.length - 1, 3);

    for (let i = 0; i < cSet.length; ++i) {
        const c = cSet[i];
        const replaced = splited.map((v, i) => {
            return v + (c.indexOf(i) > -1 ? '_' : x);
        }).join('').replace(/.$/, '');
        map.pushResult('p' + replaced, p);
    }
});

for (let key in map){
    if (map[key].length > 6) {
        console.log(key, map[key]);
    }
}


function tryPrime(i) {
    const sqrt = ~~Math.sqrt(i);
    if (primes.filter(i => i <= sqrt).every(p => i % p !== 0)) {
        primes.push(i);
    }
}


