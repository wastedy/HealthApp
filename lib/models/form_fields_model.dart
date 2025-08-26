class FormFieldsModel {
  String title, inputType;
  FormFieldsModel({required this.title, required this.inputType});
}

List<FormFieldsModel> formFieldsItems = [
  FormFieldsModel(
    title: "Nome Completo:", 
    inputType: "InputField",
    
  ),
  FormFieldsModel(
    title: "Qual o problema de saúde que você ou seu familiar está enfrentando?", 
    inputType: "InputField"
  ),
  FormFieldsModel(
    title: "Que tipo de assistência você ou seu familiar precisa? (Ex: enfermagem, fisioterapia, terapia ocupacional, etc.):", 
    inputType: "OptionField"
  ),
  FormFieldsModel(
    title: "Com que frequência você precisa da assistência?", 
    inputType: "OptionField"
  ),
  
];