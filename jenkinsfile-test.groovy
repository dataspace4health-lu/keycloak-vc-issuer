@Library(value="ds4h", changelog=false) _

properties([
    parameters([
        string(name: 'NODE_NAME', description: 'Agent to run on', defaultValue: 'any'),
        string(name: 'BRANCH', description: 'Branch to check out', defaultValue: ''),
        string(name: "PUBLISH_IMAGE", description: "Registry, image name and tag to use for publishing", defaultValue: '')
    ])
])

dockerImagePipeline(
    NODE_NAME: params.NODE_NAME,
    BRANCH: params.BRANCH,
    CUSTOM_BUILD_SCRIPT: '',
    DOCKERFILE_PATH: './deploy/Dockerfile-init-test',
    CUSTOM_LINT_SCRIPT: '', // 'npx eslint --ext ".js,.jsx,.ts,.tsx" -f checkstyle "app" "services"'
    PUBLISH_IMAGE: params.PUBLISH_IMAGE
)