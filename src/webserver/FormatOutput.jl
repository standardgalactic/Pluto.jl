using Markdown
import Base: show
import Markdown: html, htmlinline, LaTeX, withtag, htmlesc


# We add a method for the Markdown -> HTML conversion that takes a LaTeX chunk from the Markdown tree and adds our custom span
function htmlinline(io::IO, x::LaTeX)
    withtag(io, :span, :class => "tex") do
        print(io, '$')
        htmlesc(io, x.formula)
        print(io, '$')
    end
end

# This one for block equations: (double $$)
function html(io::IO, x::LaTeX)
    withtag(io, :p, :class => "tex") do
        print(io, '$', '$')
        htmlesc(io, x.formula)
        print(io, '$', '$')
    end
end

"The `IOContext` used for converting arbitrary objects to pretty strings."
iocontext = IOContext(stdout, :color => false, :compact => true, :limit => true, :displaysize => (18, 120))

"""Format `val` using the richest possible output, return formatted string and used MIME type.

Currently, the MIME type is one of `text/html` or `text/plain`, the former being richest."""
function format_output(val::Any)::Tuple{String, MIME}
    # in order of coolness
    # text/plain always matches
    mime = let
        mimes = [MIME("text/html"), MIME("text/plain")]
        first(filter(m->Base.invokelatest(showable, m, val), mimes))
    end
    
    if val === nothing
        "", mime
    else
        try
            Base.invokelatest(repr, mime, val; context = iocontext), mime
        catch ex
            Base.invokelatest(repr, mime, ex; context = iocontext), mime
        end
    end
end