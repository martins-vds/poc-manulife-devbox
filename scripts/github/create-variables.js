// @ts-check

/** 
 * @param {import('@types/github-script').AsyncFunctionArguments} AsyncFunctionArguments
 * @param {string} environment
 * @param {Array<{name: string, value: string}>} variables
 * 
*/
export default async function createVariables({ github, context }, environment, variables) {
    const owner = context.repo.owner;
    const repository = context.repo.repo;

    if (!environment) {
        throw new Error('environment is required');
    }

    if (!Array.isArray(variables)) {
        throw new Error('variables must be an array');
    }

    console.log(`Creating variables for environment ${environment}...`);

    try {
        const results = await Promise.allSettled(variables.map(variable => async () => {
            try {
                const { data } = await github.request(`POST /repos/${owner}/${repository}/environments/${environment}/variables`, {
                    owner: owner,
                    repo: repository,
                    environment_name: environment,
                    name: variable.name,
                    value: variable.value,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                });

                return {
                    variable: variable.name,
                    data: data
                };
            } catch (error) {
                if (error.status !== 409) {
                    throw error;
                }

                const { data } = await github.request(`PATCH /repos/${owner}/${repository}/environments/${environment}/variables/${variable.name}`, {
                    owner: owner,
                    repo: repository,
                    environment_name: environment,
                    name: variable.name,
                    value: variable.value,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                });

                return {
                    variable: variable.name,
                    data: data
                };
            }
        }));

        results.forEach(result => {
            if (result.status === 'fulfilled') {
                console.log('Variable created successfully', JSON.stringify(result.value()));
            } else {
                console.log('Variable creation failed', result.reason)
            }
        });
    } catch (error) {
        console.log('Error creating variables', error);
    } finally {
        console.log('Finished creating variables');
    }
}