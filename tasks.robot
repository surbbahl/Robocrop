*** Settings ***
Documentation     Order Robot from internet.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Excel.Files
Library           RPA.Tables
Library           RPA.HTTP
Library           RPA.PDF
        

*** Tasks ***
 Order Robot from internet.
    Open the intranet website.
    Enter the value for each row in csv file 
  
*** Variables ***
${csv_url}        https://robotsparebinindustries.com/orders.csv
${orders_file}    order.csv
${pdf_folder}     ${CURDIR}${/}pdf_files

${img_folder}     ${CURDIR}${/}image_files
*** Keywords ***
Open the intranet website.
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
   
Get order details
    Download    url=${csv_url}         target_file=${orders_file}    overwrite=True
    ${tables}=   Read table from CSV    path=${orders_file}
    [Return]    ${tables}

Enter the value for each row in csv file
     ${orders}=     Get order details
     FOR    ${order}    IN    @{orders}
        
        Enter the values and buy robot    ${order}
     END
Enter the values and buy robot
    [Arguments]     ${order}
    Click Button        OK
    Select From List By Value   head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text      address   ${order}[Address]
    Click Button    Preview
    Click Button    Order
   
    

    Wait Until Element Is Visible   //*[@id="robot-preview-image"]
    Sleep  5
    ${orderid}=                     Get Text            //*[@id="receipt"]/p[1]
    Set Local Variable              ${fully_qualified_img_filename}    ${img_folder}${/}${orderid}.png
     Set Local Variable      ${img_robot}        //*[@id="robot-preview-image"]
    Capture Element Screenshot      ${img_robot}    ${fully_qualified_img_filename}
    Sleep  5
    Set Local Variable             ${Order_num}    ${order}[Order number]
    Wait Until Element Is Visible   //*[@id="receipt"]
    ${order_receipt_html}=          Get Element Attribute   //*[@id="receipt"]  outerHTML
    Set Local Variable              ${fully_qualified_pdf_filename}    ${pdf_folder}${/}${Order_num}.pdf
    Html To Pdf                     content=${order_receipt_html}   output_path=${fully_qualified_pdf_filename}
    Click Button   Order another robot
    [Return]    ${fully_qualified_pdf_filename}
    