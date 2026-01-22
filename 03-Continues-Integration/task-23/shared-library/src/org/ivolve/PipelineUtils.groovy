package org.ivolve

/**
 * Pipeline Utility Class
 * Contains helper methods for Jenkins pipelines
 */
class PipelineUtils implements Serializable {
    
    /**
     * Get build number as image tag
     */
    static String getImageTag(env) {
        return env.BUILD_NUMBER ?: 'latest'
    }
    
    /**
     * Construct full image name
     */
    static String getImageName(String dockerhubUser, String repoName, String tag) {
        return "${dockerhubUser}/${repoName}:${tag}"
    }
    
    /**
     * Verify required tools are installed
     */
    static void verifyTools() {
        def tools = ['docker', 'kubectl']
        tools.each { tool ->
            def result = sh(
                script: "which ${tool} || echo 'not found'",
                returnStdout: true
            ).trim()
            if (result == 'not found') {
                echo "Warning: ${tool} not found in PATH"
            }
        }
    }
}
