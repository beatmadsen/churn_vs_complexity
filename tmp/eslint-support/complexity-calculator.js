const { ESLint } = require('eslint');

async function analyzeComplexity(files) {
    const eslint = new ESLint({
        useEslintrc: false,
        overrideConfig: {
            plugins: ['complexity'],
            parserOptions: {
                ecmaVersion: 2021,
            },
            overrides: [
                {
                    files: ['*.ts', '*.tsx'],
                    parser: '@typescript-eslint/parser',
                    plugins: ['@typescript-eslint'],
                    extends: ['plugin:@typescript-eslint/recommended'],
                },
            ],
            rules: {
                'complexity': ['warn', { max: 0 }]
            },
        },
    });

    try {
        const results = await eslint.lintFiles(files);

        const complexityResults = results.map(result => {
            const messages = result.messages.filter(msg => msg.ruleId === 'complexity');
            const complexity = messages.reduce((sum, msg) => {
                const complexityValue = parseInt(msg.message.match(/\d+/)[0], 10);
                return sum + complexityValue;
            }, 0);
            return {
                file: result.filePath,
                complexity,
            };
        });

        console.log(JSON.stringify(complexityResults));
    } catch (error) {
        console.error('Error during analysis:', error);
        process.exit(1);
    }
}

const files = JSON.parse(process.argv[2]);
analyzeComplexity(files);