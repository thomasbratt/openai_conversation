#!/bin/bash

# -----------------------------------------------------------------------------
# Generate a conversation from the OpenAI service given a prompt text.
#
# Requires the OpenAI API key to be stored in a text file named 'api.key'
# -----------------------------------------------------------------------------

OPENAI_API_KEY="$(<api.key)"
MODEL_ID='text-davinci-003'

check_arguments(){
    if [[ ${1} -ne 1 ]]; then
        printf 'Example usage: %s "prompt text"\n' "${2}" >&2
        return 1
    fi
}

generate(){
    local prompt="${1}"
    local size="${2}"
    curl --silent https://api.openai.com/v1/completions     \
        -H 'Content-Type: application/json'                 \
        -H "Authorization: Bearer ${OPENAI_API_KEY}"        \
        -d '{
                "prompt": "'"${prompt}"'",
                "model": "'"${MODEL_ID}"'",
                "temperature": 0.9,
                "max_tokens": 150,
                "top_p": 1,
                "frequency_penalty": 0,
                "presence_penalty": 0.6,
                "stop": [" Human:", " AI:"]
            }'                                              \
        | tr '[:space:]' ' '
}

generate_and_download(){
    local prompt="${1}"
    local size="${2}"
    local response
    response="$(generate "${prompt}" ${size})"                              || return $?
    response_text="$(jq '.choices[0].text' <<< "${response}")"              || return $?
    sed -E -e 's/^"//' -e 's/"$//' -e 's/^(\\n)+//' <<< "${response_text}"  || return $?
}

main(){
    local text
    check_arguments "$#" "$0"                                               || return $? 
    text="$(generate_and_download "${1}" "${2}")"                           || return $?
    printf "${text}"
}

main "$@"

