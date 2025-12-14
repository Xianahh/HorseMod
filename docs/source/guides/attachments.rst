Attachments guide
=================
Attachments on horses are handled by a bunch of different system spread across multiple modules and classes. The system currently allows you to associate an :lua:alias:`HorseMod.AttachmentSlot` to an `attachment point <https://pzwiki.net/wiki/Attachment_(scripts)>`_ on the horse model and define slots various items can occupy with different caracteristics defined as :lua:class:`HorseMod.AttachmentDefinition`.

Creating a new slot
-------------------
Slots require the use of :lua::class:`HorseMod.SlotDefinition` to associated a slot name to a model attachment point on the horse model. You can also use multiple times the same attachment point if needed. Alternatively, extra properties can be set to have the attachment be a mane attachment. 

Defining a new attachment
-------------------------
Defining a whole new attachment depends on the function :lua:obj:`HorseMod.AttachmentData.addNewAttachments`. This function allows you to add new slot and item definitions to an existing item full type or create a new item definition entry.

TODO: add example here

AttachmentsLoad
---------------

TODO: write this section