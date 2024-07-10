const owner = '${{ github.repository_owner }}'
const repository = '${{ github.repository }}'.split('/')[1]
const environment = '${{ github.event.inputs.env }}'

const variables = [
    {
        name: 'GALLERY_NAME',
        value: '${{ steps.deploy.outputs.galleryName }}'
    },
    {
        name: 'DEV_CENTER_NAME',
        value: '${{ steps.deploy.outputs.devCenterName }}'
    },
    {
        name: 'IMAGE_BUILDER_MANAGED_IDENTITY_NAME',
        value: '${{ steps.deploy.outputs.imageBuilderId }}'
    },
    {
        name: 'BASE_DEV_BOX_DEFINITION_NAME',
        value: '${{ steps.deploy.outputs.devBoxDefinitionName }}'
    },
    {
        name: 'DEV_CENTER_ATTACHED_NETWORK',
        value: '${{ steps.deploy.outputs.devCenterAttachedNetworkName }}'
    }
]

variables.forEach(variable => async () => {
    const response = await github.request(`GET /repos/${owner}/${repository}/environments/${environment}/variables/${variable.name}`, {
        owner: owner,
        repo: repository,
        environment_name: environment,
        name: variable.name,
        headers: {
            'X-GitHub-Api-Version': '2022-11-28'
        }
    })

    if (response.status === 200) {
        console.log(`Updating variable ${variable.name}...`)
        await github.request(`PATCH /repos/${owner}/${repository}/environments/${environment}/variables/${variable.name}`, {
            owner: owner,
            repo: repository,
            environment_name: environment,
            name: variable.name,
            value: variable.value,
            headers: {
                'X-GitHub-Api-Version': '2022-11-28'
            }
        })
    } else {
        console.log(`Creating variable ${variable.name}...`)        
        await github.request(`POST /repos/${owner}/${repository}/environments/${environment}/variables`, {
            owner: owner,
            repo: repository,
            environment_name: environment,
            name: variable.name,
            value: variable.value,
            headers: {
                'X-GitHub-Api-Version': '2022-11-28'
            }
        })
    }
});