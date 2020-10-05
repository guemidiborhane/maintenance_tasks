# frozen_string_literal: true
require 'test_helper'

class EnqueueTaskTest < ActionDispatch::IntegrationTest
  include MaintenanceTasks::Engine.routes.url_helpers

  test 'enqueuing a task' do
    get '/maintenance_tasks'
    assert_response :success
    assert_select 'tbody tr td', 'Maintenance::UpdatePostsTask'

    assert_enqueued_with job: Maintenance::UpdatePostsTask do
      post runs_path, params: { name: 'Maintenance::UpdatePostsTask' }
    end
    follow_redirect!
    assert_equal '/maintenance_tasks/', path
    assert_equal 'Task Maintenance::UpdatePostsTask enqueued.', flash[:notice]
  end

  test 'enqueuing an invalid task' do
    post '/maintenance_tasks/runs?name=Maintenance::DoesNotExist'
    follow_redirect!
    assert_equal '/maintenance_tasks/', path
    expected_error = 'Task Maintenance::DoesNotExist does not exist.'
    assert_equal expected_error, flash[:notice]
  end
end
