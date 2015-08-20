class Spinner < Base

  before_mount do
    define_state(:color) { params[:color] || "red"}
  end

  def render
    div id: "loader_wrapper" do
      div class_name: "preloader-wrapper big active" do
        div class_name: "spinner-layer spinner-#{self.color}-only"  do
          div class_name: "circle-clipper left" do
            div class_name: "circle" 
          end
          div class_name: "gap-patch" do
            div class_name: "circle"
          end
          div class_name:"circle-clipper right" do
            div class_name: "circle"
          end
        end
      end
    end
  end

end

