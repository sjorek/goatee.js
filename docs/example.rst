
---------------
Javascript

   v("body", document, {
     "apply"  : "@import url(http://path/to/instructions.chips)",
     "render" : {my:{custom:{data:1}}},
     "display": "my.custom.data"
   })

   v("body", document, "render")
   v("body", document, "render", {my:{custom:{data:1}}})

   v("body", document, "display")
   v("body", document, "display", "my.custom.data")

   v("body", document)
     .apply("@import url(http://path/to/instructions.chips)")
     .render({my:{custom:{data:1}}})
     .display("my.custom.data")

   v(document).apply("

   @import url(http://path/to/instructions.chips);

   body {
     render: my.custom;

     render: url(http://path.to/json);
     render: url(http://path.to/json) \"my.custom\";

     render: url('http://path.to/json');
     render: url('http://path.to/json') \"my.custom\";

     render: url(\"http://path.to/json\");
     render: url(\"http://path.to/json\") \"my.custom\";

     render: url(data:application/json,{my:{custom:{data:0}}});
     render: url(data:application/json,{my:{custom:{data:0}}}) \"my.custom\";

     render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==);
     render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==) "my.custom";

     render: data({my:{custom:{data:0}}});
     render: data({my:{custom:{data:0}}}) "my.custom";

     display: !data;
   }

   ")

---------------
jQuery.goatee

jQuery("body").v({
  "apply"  : "@import url(http://path/to/instructions.chips)",
  "render" : {my:{custom:{data:1}}},
  "display": "my.custom.data"
})

jQuery("body")
  .v("apply", "@import url(http://path/to/instructions.chips)")
  .v("render", {my:{custom:{data:1}}})
  .v("display", "my.custom.data")

jQuery.v("body")
  .apply("@import url(http://path/to/instructions.chips)"),
  .render({my:{custom:{data:1}}})
  .display("my.custom.data")


---------------
Chips

@import url(http://path/to/instructions.chips);

body {
  render: "my.custom";

  render: url(http://path.to/json);
  render: url(http://path.to/json) "my.custom";

  render: url('http://path.to/json');
  render: url('http://path.to/json') "my.custom";

  render: url("http://path.to/json");
  render: url("http://path.to/json") "my.custom";

  render: url(data:application/json,{my:{custom:{data:0}}});
  render: url(data:application/json,{my:{custom:{data:0}}}) "my.custom";

  render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==);
  render: url(data:application/json;base64,e215OntjdXN0b206e2RhdGE6MH19fQ==) "my.custom";

  render: data({my:{custom:{data:0}}});
  render: data({my:{custom:{data:0}}}) "my.custom";

  display: "!data";
}

---------------
IOM

