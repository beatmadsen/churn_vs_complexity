import { ESLint } from 'eslint';

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

async function analyzeComplexity(files) {
    const overrideConfig = tseslint.config(
        eslint.configs.recommended,
        ...tseslint.configs.recommended,
        {
            rules: {
                'complexity': ['warn', 0],
            },            
        }
    );

    const linter = new ESLint({
        overrideConfigFile: true,
        overrideConfig,
    });

    try {
        const results = await linter.lintFiles(files);
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