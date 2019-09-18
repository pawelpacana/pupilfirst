[@bs.config {jsx: 3}];

open CoursesReview__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("levels", array(Level.decode)),
    json |> field("submissions", array(Submission.decode)),
    json |> field("courseId", string),
    json |> field("gradeLabels", array(GradeLabel.decode)),
  );

let (authenticityToken, levels, submissions, courseId, gradeLabels) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReview__Root
    authenticityToken
    levels
    submissions
    courseId
    gradeLabels
  />,
  "react-root",
);
