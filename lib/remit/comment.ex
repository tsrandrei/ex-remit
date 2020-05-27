defmodule Remit.Comment do
  use Ecto.Schema
  import Ecto.Query
  alias Remit.{Repo, Commit, Comment, CommentNotification}

  @timestamps_opts [type: :utc_datetime]

  schema "comments" do
    field :github_id, :integer
    field :commit_sha, :string
    field :body, :string
    field :commented_at, :utc_datetime
    field :commenter_username, :string
    field :path, :string
    field :position, :integer

    has_many :comment_notifications, CommentNotification
    belongs_to :commit, Commit, foreign_key: :commit_sha, references: :sha, define_field: false

    timestamps()
  end

  def load_latest(count) do
    Repo.all(from c in Comment, limit: ^count, order_by: [desc: :id])
  end

  def load_other_comments_in_the_same_thread(commit) do
    Repo.all(
      from c in Comment,
        where: c.commit_sha == ^commit.commit_sha,
        where: c.id != ^commit.id
    )
  end

  # If the comment ID, file path and line position are identical, they're in the same thread.
  # Either in the same thread of line comments, or (if path and pos are nil), in the thread of non-line based commit comments.
  def same_thread?(
    %Comment{github_id: id, path: path, position: pos},
    %Comment{github_id: id, path: path, position: pos}
  ), do: true
  def same_thread?(_, _), do: false
end
