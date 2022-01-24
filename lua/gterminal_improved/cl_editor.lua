local Editor = {}

local scrw, scrh = ScrW(), ScrH()

local main = vgui.RegisterTable({
    Init = function(self)
        self:SetSize(scrw * .5, scrh * .5)
        self:Center()
        self:MakePopup()
        self:SetTitle("Text Editor")

        local text_entry = self:Add("DTextEntry")
        text_entry:Dock(FILL)
        text_entry:SetMultiline(true)
        self.text_entry = text_entry

        local save = self:Add("DButton")
        save:Dock(BOTTOM)
        save:SetText("Save")
        save.DoClick = function(s)
            net.Start("gTerminal_Improved.Editor.Save")
                net.WriteEntity(self.entity)
                net.WriteString(self.file_name)
                net.WriteString(text_entry:GetValue())
            net.SendToServer()
        end
    end,
}, "DFrame")


function Editor:Open(ent, file_name, file_content)
    self:Close()

    self.panel = vgui.CreateFromTable(main)
    self.panel.entity = ent
    self.panel.file_name = file_name

    self.panel:SetTitle("Text Editor - ".. file_name)

    self.panel.text_entry:SetText(file_content)
end

function Editor:Close()
    if IsValid(self.panel) then self.panel:Remove() end
end


net.Receive("gTerminal_Improved.Editor.Open", function()
    Editor:Open(net.ReadEntity(), net.ReadString(), net.ReadString())
end)


gTerminal.Improved.Editor = Editor