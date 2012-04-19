require "sr"

module Sr
  module MessageTypes
    # master
    CREATE_JOB = "create-job"
    COLLECTOR_CREATED = "collector-created"
    FETCHER_CREATED = "fetcher-created"
    WORKER_CREATED = "worker-created"

    # all nodes
    NEW_JOB = "new-job"
    KILL_JOB = "kill-job"

    # collector
    RESULT = "result"

    # fetcher
    FETCH = "fetch"

    # worker
    PUSH_RESULTS = "push-results"
  end
end

