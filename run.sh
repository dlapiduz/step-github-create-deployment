create_deployment() {
  set -e;

  local owner="$1";
  local repo="$2";
  local token="$3";
  local ref="$4";
  local task="$5";
  local auto_merge="$6";
  local deploy_payload="$7";
  local environment="$8";
  local description="$9";

  local payload="\"ref\":\"$ref\"";
  payload="$payload,\"task\":\"$task\"";

  if [ -n "$auto_merge" ]; then
    payload="$payload,\"auto_merge\":$auto_merge";
  fi;

  if [ -n "$deploy_payload" ]; then
    payload="$payload,\"payload\":\"$deploy_payload\"";
  fi;

  if [ -n "$environment" ]; then
    payload="$payload,\"environment\":\"$environment\"";
  fi;

  if [ -n "$description" ]; then
    payload="$payload,\"description\":\"$description\"";
  fi;

  payload="{$payload}";

  curl --fail -s -S -X POST https://api.github.com/repos/$owner/$repo/deployments \
    -A "wercker-create-deployment" \
    -H "Accept: application/vnd.github.cannonball-preview+json" \
    -H "Authorization: token $token" \
    -H "Content-Type: application/json" \
    -d "$payload";
}

export_id_to_env_var() {
  set -e;

  local json="$1";
  local export_name="$2";

  local id=$(echo "$json" | $WERCKER_STEP_ROOT/bin/jq ".id");

  info "exporting deployment id ($id) to environment variable: \$$export_name";

  export $export_name=$id;
}

info() {
  set -e;

  echo "$1";
}

main() {
  set -e;

  # Assign global variables to local variables
  local token="$WERCKER_GITHUB_CREATE_DEPLOYMENT_TOKEN";
  local ref="$WERCKER_GITHUB_CREATE_DEPLOYMENT_REF";
  local task="$WERCKER_GITHUB_CREATE_DEPLOYMENT_TASK";
  local auto_merge="$WERCKER_GITHUB_CREATE_DEPLOYMENT_AUTO_MERGE";
  local payload="$WERCKER_GITHUB_CREATE_DEPLOYMENT_PAYLOAD";
  local environment="$WERCKER_GITHUB_CREATE_DEPLOYMENT_ENVIRONMENT";
  local description="$WERCKER_GITHUB_CREATE_DEPLOYMENT_DESCRIPTION";
  local export_id="$WERCKER_GITHUB_CREATE_DEPLOYMENT_EXPORT_ID";

  local owner="$WERCKER_GIT_OWNER";
  local repo="$WERCKER_GIT_REPOSITORY";

  # Validate variables
  if [ -z "$token" ]; then
    fail "Token not specified; please add a token parameter to the step";
  fi

  if [ -z "$ref" ]; then
    ref="$WERCKER_GIT_COMMIT"
    info "Ref not specified; using default";
  fi

  if [ -z "$task" ]; then
    task="deploy"
    info "Task not specified; using default: $task";
  fi


  if [ -n "$auto_merge" ]; then
    if [ "$auto_merge" != "false" ] && [ "$auto_merge" != "true" ]; then
      fail "The parameter auto_merge has to be false or true";
    fi
  fi

  if [ -z "$export_id" ]; then
    export_id="WERCKER_GITHUB_CREATE_DEPLOYMENT_ID";
    info "no export id was supplied, using default value: $export_id";
  fi

  info "started creating $environment deployment for $ref to GitHub repo $owner/$repo";

  # Create the deployment and save the output from curl
  DEPLOY_RESPONSE=$(create_deployment \
    "$owner" \
    "$repo" \
    "$token" \
    "$ref" \
    "$task" \
    "$auto_merge" \
    "$payload" \
    "$environment" \
    "$description");

  info "finished creating $environment deployment for $ref to GitHub repo $owner/$repo";

  info "$DEPLOY_RESPONSE";

  export_id_to_env_var "$DEPLOY_RESPONSE" "$export_id";

  info "successfully created deployment on GitHub";
}

# Run the main function
main;
